#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Running tests..."
run_flutter test

info "Tests complete."
