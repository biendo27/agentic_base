#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

cd "$PROJECT_ROOT"
check_flutter

FLAVOR="${1:-}"
TARGET="${2:-}"

if [[ -z "$FLAVOR" || -z "$TARGET" ]]; then
  die "Usage: ./tools/release.sh <dev|staging|prod> <firebase|testflight|play-internal|play-production|app-store>"
fi

start_evidence_run "release" "release-readiness"
set_approval_state "UploadReady"
RUN_EXIT_CODE=0
trap 'finalize_evidence_run "$RUN_EXIT_CODE"' EXIT

firebase_artifact() {
  local flavored_apk="build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"
  local default_apk="build/app/outputs/flutter-apk/app-release.apk"
  if [[ -f "$flavored_apk" ]]; then
    printf '%s' "$flavored_apk"
    return 0
  fi
  if [[ -f "$default_apk" ]]; then
    printf '%s' "$default_apk"
    return 0
  fi
  return 1
}

run_release_preflight() {
  "$PROJECT_ROOT/tools/release-preflight.sh" "$FLAVOR" "$TARGET"
}

perform_release_upload() {
  case "$TARGET" in
    firebase)
      "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" apk
      ARTIFACT="$(firebase_artifact)" || {
        error "Could not locate the Firebase APK artifact."
        return 1
      }
      FIREBASE_ARGS=(appdistribution:distribute "$ARTIFACT" --app "${FIREBASE_APP_ID}")
      if [[ -n "${FIREBASE_GROUPS:-}" ]]; then
        FIREBASE_ARGS+=(--groups "${FIREBASE_GROUPS}")
      fi
      if [[ -n "${FIREBASE_TESTERS:-}" ]]; then
        FIREBASE_ARGS+=(--testers "${FIREBASE_TESTERS}")
      fi
      firebase "${FIREBASE_ARGS[@]}"
      set_approval_state "Uploaded"
      ;;
    testflight)
      "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" ipa
      (cd ios && bundle exec fastlane beta flavor:"$FLAVOR")
      set_approval_state "Uploaded"
      ;;
    play-internal)
      "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" appbundle
      (cd android && bundle exec fastlane internal flavor:"$FLAVOR")
      set_approval_state "Uploaded"
      ;;
    play-production)
      "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" appbundle
      (cd android && bundle exec fastlane production flavor:"$FLAVOR")
      warn "Play production uploads stay in draft until a human promotes them."
      set_approval_state "AwaitingFinalPublishApproval"
      set_next_required_human_action "final-store-publish-approval"
      ;;
    app-store)
      "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" ipa
      (cd ios && bundle exec fastlane release flavor:"$FLAVOR")
      warn "App Store uploads skip final publish. Submit when human approval is complete."
      set_approval_state "AwaitingFinalPublishApproval"
      set_next_required_human_action "final-store-publish-approval"
      ;;
    *)
      error "Unsupported release target: $TARGET"
      return 1
      ;;
  esac
}

if ! run_gate "release-preflight" "release_readiness" "[1/2] Running release preflight..." run_release_preflight; then
  RUN_EXIT_CODE=1
  exit 1
fi

if ! run_gate "artifact-upload" "release_readiness" "[2/2] Building and uploading the release artifact..." perform_release_upload; then
  RUN_EXIT_CODE=1
  exit 1
fi

info "Release upload complete for $FLAVOR/$TARGET. Evidence written to $RUN_DIR"
