#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

info "Running CI verify ladder..."
"$PROJECT_ROOT/tools/verify.sh"
