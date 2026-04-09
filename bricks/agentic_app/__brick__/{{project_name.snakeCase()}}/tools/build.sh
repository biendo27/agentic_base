#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

FLAVOR="${1:-prod}"

info "Building APK with flavor: $FLAVOR"
flutter build apk --flavor "$FLAVOR" --target "lib/main_${FLAVOR}.dart"

info "Build complete."
