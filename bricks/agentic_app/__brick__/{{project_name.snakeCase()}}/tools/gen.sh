#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Cleaning generated i18n outputs..."
rm -rf lib/app/i18n

info "Running build_runner..."
run_dart run build_runner build --delete-conflicting-outputs

info "Generating typed translations..."
run_dart run slang

info "Formatting generated code..."
run_dart format lib test

info "Code generation complete."
