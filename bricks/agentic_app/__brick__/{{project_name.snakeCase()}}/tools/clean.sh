#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Cleaning build artifacts..."
run_flutter clean

info "Fetching dependencies..."
run_flutter pub get

info "Clean complete."
