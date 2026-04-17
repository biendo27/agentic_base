#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

cd "$PROJECT_ROOT"
check_flutter

FLAVOR="${1:-}"
TARGET="${2:-}"

if [[ -z "$FLAVOR" || -z "$TARGET" ]]; then
  die "Usage: ./tools/release-preflight.sh <dev|staging|prod> <firebase|testflight|play-internal|play-production|app-store>"
fi

start_evidence_run "release-preflight" "release {{required_gate_pack}}"
set_approval_state "ApprovedForReleasePrep"
RUN_EXIT_CODE=0
trap 'finalize_evidence_run "$RUN_EXIT_CODE"' EXIT

validate_release_inputs() {
  case "$FLAVOR" in
    dev|staging|prod) ;;
    *)
      error "Unsupported flavor: $FLAVOR"
      return 1
      ;;
  esac

  case "$TARGET" in
    firebase|testflight|play-internal|play-production|app-store) ;;
    *)
      error "Unsupported release target: $TARGET"
      return 1
      ;;
  esac

  [[ -f "env/${FLAVOR}.env.example" ]] || {
    error "Missing required file: env/${FLAVOR}.env.example"
    return 1
  }
}

validate_release_prerequisites() {
  case "$TARGET" in
    firebase)
      command -v firebase >/dev/null 2>&1 || {
        error "Required command not found: firebase"
        return 1
      }
      [[ -n "${FIREBASE_APP_ID:-}" ]] || {
        error "Missing required environment variable: FIREBASE_APP_ID"
        return 1
      }
      ;;
    testflight|app-store)
      [[ "$(uname -s)" == "Darwin" ]] || {
        error "iOS release flows require macOS."
        return 1
      }
      command -v bundle >/dev/null 2>&1 || {
        error "Required command not found: bundle"
        return 1
      }
      [[ -d ios/fastlane ]] || {
        error "Missing required directory: ios/fastlane"
        return 1
      }
      [[ -f ios/fastlane/Fastfile ]] || {
        error "Missing required file: ios/fastlane/Fastfile"
        return 1
      }
      [[ -n "${APP_STORE_CONNECT_API_KEY_KEY_ID:-}" ]] || {
        error "Missing required environment variable: APP_STORE_CONNECT_API_KEY_KEY_ID"
        return 1
      }
      [[ -n "${APP_STORE_CONNECT_API_KEY_ISSUER_ID:-}" ]] || {
        error "Missing required environment variable: APP_STORE_CONNECT_API_KEY_ISSUER_ID"
        return 1
      }
      [[ -n "${APP_STORE_CONNECT_API_KEY_CONTENT:-}" ]] || {
        error "Missing required environment variable: APP_STORE_CONNECT_API_KEY_CONTENT"
        return 1
      }
      ;;
    play-internal|play-production)
      command -v bundle >/dev/null 2>&1 || {
        error "Required command not found: bundle"
        return 1
      }
      [[ -d android/fastlane ]] || {
        error "Missing required directory: android/fastlane"
        return 1
      }
      [[ -f android/fastlane/Fastfile ]] || {
        error "Missing required file: android/fastlane/Fastfile"
        return 1
      }
      [[ -n "${PLAY_STORE_JSON_KEY:-}" ]] || {
        error "Missing required environment variable: PLAY_STORE_JSON_KEY"
        return 1
      }
      ;;
  esac
}

validate_release_boundary() {
  if [[ "$TARGET" == "app-store" || "$TARGET" == "play-production" ]]; then
    warn "Final production publish remains a human approval step."
  fi
}

if ! run_gate "contract-surface" "correctness" "Validating the generated contract surface..." verify_contract_surface; then
  RUN_EXIT_CODE=1
  exit 1
fi

if ! run_gate "toolchain-contract" "release_readiness" "Validating the declared Flutter toolchain..." validate_flutter_contract; then
  RUN_EXIT_CODE=1
  exit 1
fi

if ! run_gate "release-inputs" "release_readiness" "Validating release inputs and prerequisites..." validate_release_inputs; then
  RUN_EXIT_CODE=1
  exit 1
fi

if ! run_gate "release-prereqs" "release_readiness" "Validating release credentials and tooling..." validate_release_prerequisites; then
  set_approval_state "NeedsCredentials"
  set_next_required_human_action "credential-setup"
  RUN_EXIT_CODE=1
  exit 1
fi

validate_release_boundary
set_approval_state "UploadReady"
info "Release preflight passed for $FLAVOR/$TARGET. Evidence written to $RUN_DIR"
