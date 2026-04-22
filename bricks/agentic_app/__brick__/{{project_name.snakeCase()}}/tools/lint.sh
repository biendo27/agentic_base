#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

STRICT=0
if [[ "${1:-}" == "--strict" ]]; then
  STRICT=1
  shift
fi

check_flutter

info "Running static analysis..."
if [[ "$STRICT" == "1" ]]; then
  run_dart analyze --fatal-infos "$@"
else
  run_dart analyze "$@"
fi

info "Lint complete."
