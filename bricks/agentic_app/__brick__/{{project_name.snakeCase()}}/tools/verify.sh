#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

cd "$PROJECT_ROOT"
check_flutter
start_evidence_run "verify" "{{required_gate_pack}}"
set_approval_state "EvalRunning"
export AGENTIC_RUNTIME_TELEMETRY_CONTEXT_FILE="$RUN_TELEMETRY_CONTEXT_PATH"
export AGENTIC_RUNTIME_TELEMETRY_EVENTS_FILE="$RUN_TELEMETRY_EVENTS_PATH"
export AGENTIC_RUNTIME_TELEMETRY_METRICS_FILE="$RUN_TELEMETRY_METRICS_PATH"

RUN_EXIT_CODE=0
FAST_VERIFY_MODE="${AGENTIC_VERIFY_FAST:-0}"
trap 'finalize_evidence_run "$RUN_EXIT_CODE"' EXIT

verify_static_contract() {
  "$PROJECT_ROOT/tools/gen.sh"
  run_dart analyze
}

verify_app_shell_smoke() {
  run_flutter test test/app_smoke_test.dart
}

verify_runtime_telemetry() {
  [[ -s "$RUN_TELEMETRY_EVENTS_PATH" ]] || {
    error "Missing telemetry events export."
    return 1
  }
  [[ -f "$RUN_TELEMETRY_CONTEXT_PATH" ]] || {
    error "Missing runtime context export."
    return 1
  }
  [[ -f "$RUN_TELEMETRY_METRICS_PATH" ]] || {
    error "Missing runtime metrics export."
    return 1
  }
}

verify_profile_starter_gate() {
  run_flutter test "{{{required_profile_verify_gate_test_path}}}"
}

verify_native_readiness() {
  local native_log
  native_log="$(mktemp)"
  set +e
  run_flutter build ios \
    --flavor dev \
    --simulator \
    --debug \
    --target lib/main_dev.dart \
    --dart-define-from-file=env/dev.env.example >"$native_log" 2>&1
  local exit_code=$?
  set -e
  cat "$native_log"

  if [[ $exit_code -eq 0 ]]; then
    rm -f "$native_log"
    return 0
  fi

  if grep -q "CocoaPods's specs repository is too out-of-date" "$native_log"; then
    override_gate_state \
      "blocked" \
      "Native readiness blocked by stale CocoaPods specs on this host. Run \`pod repo update\` and rerun verify."
    set_next_required_human_action "refresh-host-ios-tooling"
    rm -f "$native_log"
    return 0
  fi

  rm -f "$native_log"
  return $exit_code
}

if ! run_gate "contract-surface" "correctness" "Validating the harness contract surface..." verify_contract_surface; then
  RUN_EXIT_CODE=1
  exit 1
fi

if ! run_gate "toolchain-contract" "correctness" "Validating the declared Flutter toolchain..." validate_flutter_contract; then
  RUN_EXIT_CODE=1
  exit 1
fi

if [[ "$FAST_VERIFY_MODE" == "1" ]]; then
  skip_gate "static" "correctness" "Static gate skipped by AGENTIC_VERIFY_FAST."
else
  if ! run_gate "static" "correctness" "Refreshing generated outputs and running static analysis..." verify_static_contract; then
    RUN_EXIT_CODE=1
    exit 1
  fi
fi

if [[ "$FAST_VERIFY_MODE" == "1" ]]; then
  skip_gate "unit-widget" "correctness" "Unit and widget gate skipped by AGENTIC_VERIFY_FAST."
else
  if ! run_gate "unit-widget" "correctness" "Running unit and widget tests..." run_flutter test --exclude-tags app-smoke; then
    RUN_EXIT_CODE=1
    exit 1
  fi
fi

if [[ -f "$PROJECT_ROOT/test/app_smoke_test.dart" ]]; then
  if ! run_gate "app-shell-smoke" "ux_confidence" "Running the starter app-shell smoke path..." verify_app_shell_smoke; then
    RUN_EXIT_CODE=1
    exit 1
  fi
else
  skip_gate "app-shell-smoke" "ux_confidence" "Starter app-shell smoke test is not present."
fi

if [[ -f "$PROJECT_ROOT/test/app_smoke_test.dart" ]]; then
  if ! run_gate "runtime-telemetry" "evidence_quality" "Exporting runtime telemetry from the starter smoke path..." verify_runtime_telemetry; then
    RUN_EXIT_CODE=1
    exit 1
  fi
else
  skip_gate "runtime-telemetry" "evidence_quality" "Runtime telemetry export is skipped without app smoke coverage."
fi

{{#has_required_profile_verify_gate}}
if ! run_gate "{{required_profile_verify_gate_id}}" "{{required_profile_verify_gate_dimension}}" "Running {{required_profile_verify_gate_label}}..." verify_profile_starter_gate; then
  RUN_EXIT_CODE=1
  exit 1
fi
{{/has_required_profile_verify_gate}}
{{^has_required_profile_verify_gate}}
{{#has_advisory_profile_verify_gate}}
skip_gate "profile-advisory" "ux_confidence" "{{advisory_profile_verify_gate_label}}"
{{/has_advisory_profile_verify_gate}}
{{/has_required_profile_verify_gate}}

if [[ "$FAST_VERIFY_MODE" == "1" ]]; then
  skip_gate "native-readiness" "release_readiness" "Native readiness skipped by AGENTIC_VERIFY_FAST."
elif [[ "${AGENTIC_SKIP_NATIVE_READINESS:-0}" == "1" ]]; then
  skip_gate "native-readiness" "release_readiness" "Native readiness skipped by AGENTIC_SKIP_NATIVE_READINESS."
{{#has_ios}}
elif [[ "$(uname -s)" == "Darwin" && -d ios ]]; then
  if ! run_gate "native-readiness" "release_readiness" "Checking iOS simulator readiness..." verify_native_readiness; then
    RUN_EXIT_CODE=1
    exit 1
  fi
else
  skip_gate "native-readiness" "release_readiness" "iOS simulator readiness only runs on Darwin hosts with ios/."
{{/has_ios}}
{{^has_ios}}
else
  skip_gate "native-readiness" "release_readiness" "iOS simulator readiness skipped because ios platform is not selected."
{{/has_ios}}
fi

if [[ "$(overall_run_state)" == "pass" ]]; then
  set_approval_state "ReadyForReview"
fi
info "Verify complete. Evidence written to $RUN_DIR"
