#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Running code generation..."
dart run build_runner build --delete-conflicting-outputs

info "Formatting generated code..."
dart format lib test

info "Code generation complete."
