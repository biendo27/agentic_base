#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

FLAVOR="${1:-prod}"

case "$FLAVOR" in
  dev|staging|prod) ;;
  *)
    err "Unsupported flavor: $FLAVOR"
    exit 1
    ;;
esac

info "Building APK with flavor: $FLAVOR"
flutter build apk \
  --flavor "$FLAVOR" \
  --target "lib/main_${FLAVOR}.dart" \
  --dart-define-from-file="env/${FLAVOR}.env.example"

if [[ "$FLAVOR" == "prod" ]]; then
  info "Building App Bundle with flavor: $FLAVOR"
  flutter build appbundle \
    --flavor "$FLAVOR" \
    --target "lib/main_${FLAVOR}.dart" \
    --dart-define-from-file="env/${FLAVOR}.env.example"
fi

info "Build complete."
