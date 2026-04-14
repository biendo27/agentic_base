#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

info "Formatting lib/ and test/..."
run_dart format lib test

info "Format complete."
