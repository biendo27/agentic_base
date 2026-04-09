#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Installing dependencies..."
flutter pub get

info "Running initial code generation..."
dart run build_runner build --delete-conflicting-outputs

info "Setup complete. Run 'flutter run --flavor dev' to start."
