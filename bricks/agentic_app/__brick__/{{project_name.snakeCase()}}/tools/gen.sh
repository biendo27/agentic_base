#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Cleaning generated i18n outputs..."
rm -rf lib/app/i18n

info "Running build_runner..."
dart run build_runner build --delete-conflicting-outputs

info "Generating typed translations..."
dart run slang

info "Formatting generated code..."
dart format lib test

info "Code generation complete."
