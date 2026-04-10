#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Installing dependencies..."
flutter pub get

info "Cleaning generated i18n outputs..."
rm -rf lib/app/i18n

info "Running build_runner..."
dart run build_runner build --delete-conflicting-outputs

info "Generating typed translations..."
dart run slang

info "Setup complete. Run 'flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.env.example' to start."
