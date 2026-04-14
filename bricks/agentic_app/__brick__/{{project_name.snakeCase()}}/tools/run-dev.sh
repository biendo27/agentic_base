#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter
cd "$PROJECT_ROOT"

info "Running the dev flavor..."
run_flutter run \
  --flavor dev \
  --target lib/main_dev.dart \
  --dart-define-from-file=env/dev.env.example \
  "$@"
