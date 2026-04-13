#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter
cd "$PROJECT_ROOT"

info "Installing dependencies..."
flutter pub get

"$PROJECT_ROOT/tools/gen.sh"

info "Setup complete. Run './tools/run-dev.sh' to start."
