#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

cd "$PROJECT_ROOT"
check_flutter
start_evidence_run "verify" "{{required_gate_pack}}"
set_approval_state "EvalRunning"

RUN_EXIT_CODE=0
trap 'finalize_evidence_run "$RUN_EXIT_CODE"' EXIT

verify_static_contract() {
  "$PROJECT_ROOT/tools/gen.sh"
  run_dart analyze
}

verify_app_shell_smoke() {
  run_flutter test test/app_smoke_test.dart
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

if ! run_gate "contract-surface" "correctness" "[1/6] Validating the harness contract surface..." verify_contract_surface; then
  RUN_EXIT_CODE=1
  exit 1
fi

if ! run_gate "toolchain-contract" "correctness" "[2/6] Validating the declared Flutter toolchain..." validate_flutter_contract; then
  RUN_EXIT_CODE=1
  exit 1
fi

if ! run_gate "static" "correctness" "[3/6] Refreshing generated outputs and running static analysis..." verify_static_contract; then
  RUN_EXIT_CODE=1
  exit 1
fi

if ! run_gate "unit-widget" "correctness" "[4/6] Running unit and widget tests..." run_flutter test --exclude-tags app-smoke; then
  RUN_EXIT_CODE=1
  exit 1
fi

if [[ -f "$PROJECT_ROOT/test/app_smoke_test.dart" ]]; then
  if ! run_gate "app-shell-smoke" "ux_confidence" "[5/6] Running the starter app-shell smoke path..." verify_app_shell_smoke; then
    RUN_EXIT_CODE=1
    exit 1
  fi
else
  skip_gate "app-shell-smoke" "ux_confidence" "Starter app-shell smoke test is not present."
fi

if [[ "$(uname -s)" == "Darwin" && -d ios ]]; then
  if ! run_gate "native-readiness" "release_readiness" "[6/6] Checking iOS simulator readiness..." verify_native_readiness; then
    RUN_EXIT_CODE=1
    exit 1
  fi
else
  skip_gate "native-readiness" "release_readiness" "iOS simulator readiness only runs on Darwin hosts with ios/."
fi

if [[ "$(overall_run_state)" == "pass" ]]; then
  set_approval_state "ReadyForReview"
fi
info "Verify complete. Evidence written to $RUN_DIR"
