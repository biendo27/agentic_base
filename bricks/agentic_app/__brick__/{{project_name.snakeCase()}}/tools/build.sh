#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter
cd "$PROJECT_ROOT"

FLAVOR="${1:-prod}"
ARTIFACT="${2:-auto}"

case "$FLAVOR" in
  dev|staging|prod) ;;
  *)
    die "Unsupported flavor: $FLAVOR"
    ;;
esac

build_apk() {
  info "Building APK with flavor: $FLAVOR"
  flutter build apk \
    --flavor "$FLAVOR" \
    --target "lib/main_${FLAVOR}.dart" \
    --dart-define-from-file="env/${FLAVOR}.env.example"
}

build_appbundle() {
  info "Building App Bundle with flavor: $FLAVOR"
  flutter build appbundle \
    --flavor "$FLAVOR" \
    --target "lib/main_${FLAVOR}.dart" \
    --dart-define-from-file="env/${FLAVOR}.env.example"
}

build_ipa() {
  [[ "$(uname -s)" == "Darwin" ]] || die "IPA builds require macOS."
  require_dir ios
  info "Building IPA with flavor: $FLAVOR"
  flutter build ipa \
    --flavor "$FLAVOR" \
    --target "lib/main_${FLAVOR}.dart" \
    --dart-define-from-file="env/${FLAVOR}.env.example"
}

case "$ARTIFACT" in
  auto)
    if [[ "$FLAVOR" == "prod" ]]; then
      build_appbundle
    else
      build_apk
    fi
    ;;
  apk)
    build_apk
    ;;
  appbundle)
    build_appbundle
    ;;
  ipa)
    build_ipa
    ;;
  all)
    build_apk
    build_appbundle
    if [[ -d ios ]]; then
      build_ipa
    fi
    ;;
  *)
    die "Unsupported artifact type: $ARTIFACT"
    ;;
esac

info "Build complete."
