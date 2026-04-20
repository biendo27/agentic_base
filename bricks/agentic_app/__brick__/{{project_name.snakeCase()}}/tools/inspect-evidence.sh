#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

cd "$PROJECT_ROOT"

RUN_KIND="${1:-verify}"
RUN_TARGET="${2:-latest}"
FORMAT="${3:-markdown}"
RUN_DIR="$PROJECT_ROOT/$(manifest_evidence_dir)/$RUN_KIND/$RUN_TARGET"

if command -v agentic_base >/dev/null 2>&1; then
  if [[ "$RUN_TARGET" == "latest" ]]; then
    exec agentic_base inspect --kind "$RUN_KIND" --format "$FORMAT"
  fi
  exec agentic_base inspect "$RUN_DIR" --format "$FORMAT"
fi

warn "agentic_base is not available. Falling back to raw evidence output."
if [[ ! -d "$RUN_DIR" ]]; then
  die "Missing evidence run: $RUN_DIR"
fi

if [[ "$FORMAT" == "json" && -f "$RUN_DIR/summary.json" ]]; then
  cat "$RUN_DIR/summary.json"
  exit 0
fi

if [[ -f "$RUN_DIR/summary.json" ]]; then
  cat "$RUN_DIR/summary.json"
  printf '\n'
fi

if [[ -f "$RUN_DIR/telemetry/metrics.json" ]]; then
  cat "$RUN_DIR/telemetry/metrics.json"
fi
