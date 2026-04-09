#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Running CI check..."

info "[1/3] Static analysis..."
dart analyze

info "[2/3] Running tests..."
flutter test

info "[3/3] CI check passed."
