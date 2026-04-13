#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter
cd "$PROJECT_ROOT"

info "[1/4] Refreshing generated sources..."
"$PROJECT_ROOT/tools/gen.sh"

info "[2/4] Static analysis..."
dart analyze

info "[3/4] Running tests..."
flutter test

if [[ "$(uname -s)" == "Darwin" && -d ios ]]; then
  info "[4/4] Checking iOS dev simulator build..."
  flutter build ios \
    --flavor dev \
    --simulator \
    --debug \
    --target lib/main_dev.dart \
    --dart-define-from-file=env/dev.env.example
else
  info "[4/4] Skipping iOS simulator readiness on this host."
fi

info "Verify complete."
