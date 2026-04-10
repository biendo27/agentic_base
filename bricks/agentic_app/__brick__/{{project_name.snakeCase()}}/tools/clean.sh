#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Cleaning build artifacts..."
flutter clean

info "Fetching dependencies..."
flutter pub get

info "Clean complete."
