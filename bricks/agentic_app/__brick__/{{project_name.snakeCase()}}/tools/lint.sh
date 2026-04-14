#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Running static analysis..."
run_dart analyze

info "Lint complete."
