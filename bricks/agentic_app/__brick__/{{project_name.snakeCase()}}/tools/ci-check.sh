#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Running CI check..."

step_total=5
if [[ "$(uname -s)" == "Darwin" && -d ios && -f lib/main_dev.dart ]]; then
  step_total=6
fi

info "[1/${step_total}] Cleaning generated i18n outputs..."
rm -rf lib/app/i18n

info "[2/${step_total}] Code generation..."
dart run build_runner build --delete-conflicting-outputs

info "[3/${step_total}] Generating typed translations..."
dart run slang

info "[4/${step_total}] Static analysis..."
dart analyze

info "[5/${step_total}] Running tests..."
flutter test

if [[ "${step_total}" -eq 6 ]]; then
  info "[6/6] Building iOS dev simulator target..."
  flutter build ios \
    --flavor dev \
    --simulator \
    --debug \
    -t lib/main_dev.dart \
    --dart-define-from-file=env/dev.env.example
fi

info "CI check passed."
