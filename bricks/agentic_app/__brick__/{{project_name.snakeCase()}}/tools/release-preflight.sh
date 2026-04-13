#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter
cd "$PROJECT_ROOT"

FLAVOR="${1:-}"
TARGET="${2:-}"

if [[ -z "$FLAVOR" || -z "$TARGET" ]]; then
  die "Usage: ./tools/release-preflight.sh <dev|staging|prod> <firebase|testflight|play-internal|play-production|app-store>"
fi

case "$FLAVOR" in
  dev|staging|prod) ;;
  *)
    die "Unsupported flavor: $FLAVOR"
    ;;
esac

require_file "env/${FLAVOR}.env.example"

case "$TARGET" in
  firebase)
    check_cmd firebase
    require_env FIREBASE_APP_ID
    if [[ -z "${FIREBASE_GROUPS:-}" && -z "${FIREBASE_TESTERS:-}" ]]; then
      warn "Set FIREBASE_GROUPS or FIREBASE_TESTERS to route the uploaded build."
    fi
    ;;
  testflight|app-store)
    [[ "$(uname -s)" == "Darwin" ]] || die "iOS release flows require macOS."
    check_cmd bundle
    require_dir ios/fastlane
    require_file ios/fastlane/Fastfile
    require_env APP_STORE_CONNECT_API_KEY_KEY_ID
    require_env APP_STORE_CONNECT_API_KEY_ISSUER_ID
    require_env APP_STORE_CONNECT_API_KEY_CONTENT
    ;;
  play-internal|play-production)
    check_cmd bundle
    require_dir android/fastlane
    require_file android/fastlane/Fastfile
    require_env PLAY_STORE_JSON_KEY
    ;;
  *)
    die "Unsupported release target: $TARGET"
    ;;
esac

if [[ "$TARGET" == "app-store" || "$TARGET" == "play-production" ]]; then
  warn "Final production publish remains a human approval step."
fi

info "Release preflight passed for $FLAVOR/$TARGET."
