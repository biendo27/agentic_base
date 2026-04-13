#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter
cd "$PROJECT_ROOT"

FLAVOR="${1:-}"
TARGET="${2:-}"

if [[ -z "$FLAVOR" || -z "$TARGET" ]]; then
  die "Usage: ./tools/release.sh <dev|staging|prod> <firebase|testflight|play-internal|play-production|app-store>"
fi

"$PROJECT_ROOT/tools/release-preflight.sh" "$FLAVOR" "$TARGET"

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

case "$TARGET" in
  firebase)
    "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" apk
    ARTIFACT="$(firebase_artifact)" || die "Could not locate the Firebase APK artifact."
    FIREBASE_ARGS=(appdistribution:distribute "$ARTIFACT" --app "${FIREBASE_APP_ID}")
    if [[ -n "${FIREBASE_GROUPS:-}" ]]; then
      FIREBASE_ARGS+=(--groups "${FIREBASE_GROUPS}")
    fi
    if [[ -n "${FIREBASE_TESTERS:-}" ]]; then
      FIREBASE_ARGS+=(--testers "${FIREBASE_TESTERS}")
    fi
    firebase "${FIREBASE_ARGS[@]}"
    ;;
  testflight)
    "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" ipa
    (cd ios && bundle exec fastlane beta flavor:"$FLAVOR")
    ;;
  play-internal)
    "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" appbundle
    (cd android && bundle exec fastlane internal flavor:"$FLAVOR")
    ;;
  play-production)
    "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" appbundle
    (cd android && bundle exec fastlane production flavor:"$FLAVOR")
    warn "Play production uploads stay in draft until a human promotes them."
    ;;
  app-store)
    "$PROJECT_ROOT/tools/build.sh" "$FLAVOR" ipa
    (cd ios && bundle exec fastlane release flavor:"$FLAVOR")
    warn "App Store uploads skip final publish. Submit when human approval is complete."
    ;;
  *)
    die "Unsupported release target: $TARGET"
    ;;
esac

info "Release upload complete for $FLAVOR/$TARGET."
