#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

cd "$PROJECT_ROOT"

if [[ $# -eq 0 ]]; then
  die "Usage: ./tools/setup-firebase.sh --project <firebase-project-id> [agentic_base firebase setup args...]"
fi

agentic_base firebase setup --project-dir "$PROJECT_ROOT" "$@"
