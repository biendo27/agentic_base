#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
die() { error "$1"; exit 1; }

MANIFEST_PATH="$PROJECT_ROOT/.info/agentic.yaml"
FLUTTER_BIN=()
DART_BIN=()

RUN_KIND=""
RUN_ID=""
RUN_TIMESTAMP=""
RUN_DIR=""
RUN_LOG_PATH=""
RUN_COMMANDS_PATH=""
RUN_SUMMARY_PATH=""
RUN_TELEMETRY_DIR=""
RUN_TELEMETRY_CONTEXT_PATH=""
RUN_TELEMETRY_EVENTS_PATH=""
RUN_TELEMETRY_METRICS_PATH=""
RUN_EXPECTATION_ID="core"
NEXT_REQUIRED_HUMAN_ACTION="none"
APPROVAL_STATE="Draft"
QUALITY_CORRECTNESS="not_run"
QUALITY_RELEASE_READINESS="not_run"
QUALITY_EVIDENCE_QUALITY="not_run"
QUALITY_UX_CONFIDENCE="not_run"
EXECUTED_GATES=()
EXECUTED_GATE_STATES=()
GATE_STATE_OVERRIDE=""
GATE_SUMMARY_OVERRIDE=""

json_escape() {
  local value="${1:-}"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

current_timestamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

check_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "Required command not found: $1"
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    die "Missing required file: $1"
  fi
}

require_dir() {
  if [[ ! -d "$1" ]]; then
    die "Missing required directory: $1"
  fi
}

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    die "Missing required environment variable: $name"
  fi
}

manifest_nested_scalar() {
  local section="$1"
  local subsection="$2"
  local key="$3"
  if [[ ! -f "$MANIFEST_PATH" ]]; then
    return 1
  fi

  awk -v section="$section" -v subsection="$subsection" -v key="$key" '
    $0 ~ "^" section ":" { in_section=1; next }
    in_section && $0 ~ "^[^ ]" { in_section=0; in_subsection=0 }
    in_section && $0 ~ "^  " subsection ":" { in_subsection=1; next }
    in_section && $0 ~ "^  [^ ]" && $0 !~ "^  " subsection ":" { in_subsection=0 }
    in_subsection && $0 ~ "^    " key ":" {
      sub("^    " key ":[[:space:]]*", "", $0)
      gsub(/^["'"'"']|["'"'"']$/, "", $0)
      print $0
      exit
    }
  ' "$MANIFEST_PATH"
}

manifest_evidence_dir() {
  local value
  value="$(manifest_nested_scalar harness eval evidence_dir 2>/dev/null || true)"
  printf '%s' "${value:-artifacts/evidence}"
}

manifest_sdk_manager() {
  local value
  value="$(manifest_nested_scalar harness sdk manager 2>/dev/null || true)"
  printf '%s' "${value:-system}"
}

manifest_sdk_channel() {
  local value
  value="$(manifest_nested_scalar harness sdk channel 2>/dev/null || true)"
  printf '%s' "${value:-stable}"
}

manifest_sdk_version() {
  local value
  value="$(manifest_nested_scalar harness sdk version 2>/dev/null || true)"
  printf '%s' "${value:-{{flutter_sdk_version}}}"
}

resolve_toolchain_commands() {
  local manager
  manager="$(manifest_sdk_manager)"
  case "$manager" in
    system)
      FLUTTER_BIN=(flutter)
      DART_BIN=(dart)
      ;;
    fvm)
      FLUTTER_BIN=(fvm flutter)
      DART_BIN=(fvm dart)
      ;;
    puro)
      FLUTTER_BIN=(puro flutter)
      DART_BIN=(puro dart)
      ;;
    *)
      die "Unsupported Flutter SDK manager: $manager"
      ;;
  esac
}

check_flutter() {
  resolve_toolchain_commands
  case "$(manifest_sdk_manager)" in
    system)
      check_cmd flutter
      check_cmd dart
      ;;
    fvm)
      check_cmd fvm
      ;;
    puro)
      check_cmd puro
      ;;
  esac
}

run_flutter() {
  "${FLUTTER_BIN[@]}" "$@"
}

run_dart() {
  "${DART_BIN[@]}" "$@"
}

validate_flutter_contract() {
  check_flutter

  local output expected_version expected_channel actual_version actual_channel
  if ! output="$("${FLUTTER_BIN[@]}" --version 2>&1)"; then
    error "Failed to resolve Flutter version via ${FLUTTER_BIN[*]}"
    return 1
  fi

  expected_version="$(manifest_sdk_version)"
  expected_channel="$(manifest_sdk_channel)"
  actual_version="$(printf '%s' "$output" | sed -nE 's/.*Flutter ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n1)"
  actual_channel="$(printf '%s' "$output" | sed -nE 's/.*channel ([A-Za-z0-9_-]+).*/\1/p' | head -n1 | tr '[:upper:]' '[:lower:]')"

  if [[ -z "$actual_version" ]]; then
    error "Could not parse the local Flutter version."
    return 1
  fi

  if [[ "$actual_version" != "$expected_version" ]]; then
    error "Flutter contract mismatch. Expected version $expected_version, found $actual_version."
    return 1
  fi

  if [[ -n "$expected_channel" && -n "$actual_channel" && "$actual_channel" != "$expected_channel" ]]; then
    error "Flutter contract mismatch. Expected channel $expected_channel, found $actual_channel."
    return 1
  fi

  return 0
}

verify_contract_surface() {
  require_file "$MANIFEST_PATH"
  require_file "$PROJECT_ROOT/README.md"
  require_file "$PROJECT_ROOT/AGENTS.md"
  require_file "$PROJECT_ROOT/CLAUDE.md"
  require_file "$PROJECT_ROOT/tools/verify.sh"
  require_file "$PROJECT_ROOT/tools/inspect-evidence.sh"
  require_file "$PROJECT_ROOT/tools/release-preflight.sh"
  require_file "$PROJECT_ROOT/tools/release.sh"
  [[ -n "$(manifest_nested_scalar harness app_profile primary_profile 2>/dev/null || true)" ]] || {
    error "Harness app profile is missing from .info/agentic.yaml."
    return 1
  }
  [[ -n "$(manifest_evidence_dir)" ]] || {
    error "Harness evidence_dir is missing from .info/agentic.yaml."
    return 1
  }
}

start_evidence_run() {
  local run_kind="$1"
  local expectation_id="${2:-core}"
  RUN_KIND="$run_kind"
  RUN_EXPECTATION_ID="$expectation_id"
  RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
  RUN_TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  RUN_DIR="$PROJECT_ROOT/$(manifest_evidence_dir)/$RUN_KIND/$RUN_ID"
  RUN_LOG_PATH="$RUN_DIR/logs/$RUN_KIND.log"
  RUN_COMMANDS_PATH="$RUN_DIR/commands.ndjson"
  RUN_SUMMARY_PATH="$RUN_DIR/summary.json"
  RUN_TELEMETRY_DIR="$RUN_DIR/telemetry"
  RUN_TELEMETRY_CONTEXT_PATH="$RUN_TELEMETRY_DIR/runtime-context.json"
  RUN_TELEMETRY_EVENTS_PATH="$RUN_TELEMETRY_DIR/events.ndjson"
  RUN_TELEMETRY_METRICS_PATH="$RUN_TELEMETRY_DIR/metrics.json"
  mkdir -p "$RUN_DIR/checks" "$RUN_DIR/logs" "$RUN_DIR/artifacts" "$RUN_TELEMETRY_DIR"
  : > "$RUN_LOG_PATH"
  : > "$RUN_COMMANDS_PATH"
  : > "$RUN_TELEMETRY_EVENTS_PATH"
  EXECUTED_GATES=()
  EXECUTED_GATE_STATES=()
  QUALITY_CORRECTNESS="not_run"
  QUALITY_RELEASE_READINESS="not_run"
  QUALITY_EVIDENCE_QUALITY="not_run"
  QUALITY_UX_CONFIDENCE="not_run"
  NEXT_REQUIRED_HUMAN_ACTION="none"
  GATE_STATE_OVERRIDE=""
  GATE_SUMMARY_OVERRIDE=""
}

set_next_required_human_action() {
  NEXT_REQUIRED_HUMAN_ACTION="$1"
  printf '{"ts":"%s","kind":"approval_transition","source":"run_control","run_id":"%s","name":"next_required_human_action","state_or_level":"pending","attrs":{"action":"%s"}}\n' \
    "$(current_timestamp)" \
    "$(json_escape "$RUN_ID")" \
    "$(json_escape "$NEXT_REQUIRED_HUMAN_ACTION")" >> "$RUN_TELEMETRY_EVENTS_PATH"
}

set_approval_state() {
  APPROVAL_STATE="$1"
  printf '{"ts":"%s","kind":"approval_transition","source":"run_control","run_id":"%s","name":"approval_state","state_or_level":"%s","attrs":{"run_kind":"%s"}}\n' \
    "$(current_timestamp)" \
    "$(json_escape "$RUN_ID")" \
    "$(json_escape "$APPROVAL_STATE")" \
    "$(json_escape "$RUN_KIND")" >> "$RUN_TELEMETRY_EVENTS_PATH"
}

record_command() {
  local gate="$1"
  local command_string="$2"
  printf '{"timestamp":"%s","gate":"%s","command":"%s"}\n' \
    "$(current_timestamp)" \
    "$(json_escape "$gate")" \
    "$(json_escape "$command_string")" >> "$RUN_COMMANDS_PATH"
}

record_gate_state() {
  EXECUTED_GATES+=("$1")
  EXECUTED_GATE_STATES+=("$2")
}

update_quality_state() {
  local dimension="$1"
  local state="$2"
  case "$dimension" in
    correctness)
      QUALITY_CORRECTNESS="$state"
      ;;
    release_readiness)
      QUALITY_RELEASE_READINESS="$state"
      ;;
    evidence_quality)
      QUALITY_EVIDENCE_QUALITY="$state"
      ;;
    ux_confidence)
      QUALITY_UX_CONFIDENCE="$state"
      ;;
  esac
}

write_check_file() {
  local gate="$1"
  local state="$2"
  local command_string="$3"
  local summary="$4"
  local timestamp
  timestamp="$(current_timestamp)"
  cat > "$RUN_DIR/checks/$gate.json" <<EOF
{
  "timestamp": "$(json_escape "$timestamp")",
  "gate": "$(json_escape "$gate")",
  "state": "$(json_escape "$state")",
  "command": "$(json_escape "$command_string")",
  "summary": "$(json_escape "$summary")",
  "log": "$(json_escape "logs/$RUN_KIND.log")"
}
EOF
}

override_gate_state() {
  GATE_STATE_OVERRIDE="$1"
  GATE_SUMMARY_OVERRIDE="${2:-}"
}

run_gate() {
  local gate="$1"
  local dimension="$2"
  local message="$3"
  shift 3
  local command_string="$*"
  info "$message"
  record_command "$gate" "$command_string"
  GATE_STATE_OVERRIDE=""
  GATE_SUMMARY_OVERRIDE=""
  set +e
  "$@" >> "$RUN_LOG_PATH" 2>&1
  local exit_code=$?
  set -e
  local state="pass"
  local summary="$message"
  if [[ -n "$GATE_STATE_OVERRIDE" ]]; then
    state="$GATE_STATE_OVERRIDE"
    if [[ -n "$GATE_SUMMARY_OVERRIDE" ]]; then
      summary="$GATE_SUMMARY_OVERRIDE"
    fi
    exit_code=0
  elif [[ $exit_code -ne 0 ]]; then
    state="fail"
  fi
  record_gate_state "$gate" "$state"
  write_check_file "$gate" "$state" "$command_string" "$summary"
  update_quality_state "$dimension" "$state"
  return $exit_code
}

skip_gate() {
  local gate="$1"
  local dimension="$2"
  local reason="$3"
  record_gate_state "$gate" "skipped"
  write_check_file "$gate" "skipped" "" "$reason"
  if [[ "$dimension" == "evidence_quality" && "$QUALITY_EVIDENCE_QUALITY" == "not_run" ]]; then
    update_quality_state "$dimension" "risk"
  fi
}

block_gate() {
  local gate="$1"
  local dimension="$2"
  local reason="$3"
  record_gate_state "$gate" "blocked"
  write_check_file "$gate" "blocked" "" "$reason"
  update_quality_state "$dimension" "blocked"
}

overall_run_state() {
  local state="pass"
  local index
  for ((index = 0; index < ${#EXECUTED_GATE_STATES[@]}; index++)); do
    case "${EXECUTED_GATE_STATES[$index]}" in
      blocked)
        printf '%s' "blocked"
        return 0
        ;;
      fail)
        state="fail"
        ;;
    esac
  done
  printf '%s' "$state"
}

executed_gates_json() {
  local gates_json=""
  local index
  for ((index = 0; index < ${#EXECUTED_GATES[@]}; index++)); do
    local prefix=""
    [[ $index -gt 0 ]] && prefix=","
    gates_json+="$prefix{\"id\":\"$(json_escape "${EXECUTED_GATES[$index]}")\",\"state\":\"$(json_escape "${EXECUTED_GATE_STATES[$index]}")\"}"
  done
  printf '%s' "$gates_json"
}

finalize_evidence_run() {
  local exit_code="${1:-0}"
  local run_root latest_path latest_tmp_path
  if [[ "$QUALITY_EVIDENCE_QUALITY" == "not_run" ]]; then
    QUALITY_EVIDENCE_QUALITY="pass"
  fi
  if [[ ! -f "$RUN_TELEMETRY_CONTEXT_PATH" ]]; then
    cat > "$RUN_TELEMETRY_CONTEXT_PATH" <<EOF
{
  "run_id": "$(json_escape "$RUN_ID")",
  "run_kind": "$(json_escape "$RUN_KIND")",
  "timestamp": "$(json_escape "$RUN_TIMESTAMP")",
  "mode": "local-first",
  "exported": false
}
EOF
  fi
  if [[ ! -f "$RUN_TELEMETRY_METRICS_PATH" ]]; then
    cat > "$RUN_TELEMETRY_METRICS_PATH" <<EOF
{
  "counters": {},
  "durations": {}
}
EOF
  fi
  cat > "$RUN_SUMMARY_PATH" <<EOF
{
  "run_id": "$(json_escape "$RUN_ID")",
  "run_kind": "$(json_escape "$RUN_KIND")",
  "timestamp": "$(json_escape "$RUN_TIMESTAMP")",
  "repo_manifest_snapshot": ".info/agentic.yaml",
  "derived_gate_expectation_id": "$(json_escape "$RUN_EXPECTATION_ID")",
  "approval_state": "$(json_escape "$APPROVAL_STATE")",
  "overall_state": "$(json_escape "$(overall_run_state)")",
  "exit_code": $exit_code,
  "executed_gates": [$(executed_gates_json)],
  "quality_dimensions": {
    "correctness": "$(json_escape "$QUALITY_CORRECTNESS")",
    "release_readiness": "$(json_escape "$QUALITY_RELEASE_READINESS")",
    "evidence_quality": "$(json_escape "$QUALITY_EVIDENCE_QUALITY")",
    "ux_confidence": "$(json_escape "$QUALITY_UX_CONFIDENCE")"
  },
  "next_required_human_action": "$(json_escape "$NEXT_REQUIRED_HUMAN_ACTION")"
}
EOF
  run_root="$PROJECT_ROOT/$(manifest_evidence_dir)/$RUN_KIND"
  latest_path="$run_root/latest"
  latest_tmp_path="$run_root/.latest-$RUN_ID"
  rm -f "$latest_tmp_path"
  ln -s "$RUN_ID" "$latest_tmp_path"
  rm -rf "$latest_path"
  mv "$latest_tmp_path" "$latest_path"
}
