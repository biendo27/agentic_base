#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter
cd "$PROJECT_ROOT"

usage() {
  cat <<'USAGE'
Usage: ./tools/run.sh [dev|staging|stg|prod] [flutter run args...]

Examples:
  ./tools/run.sh
  ./tools/run.sh staging -d emulator-5554
  ./tools/run.sh -d chrome
USAGE
}

FLAVOR="dev"
if [[ $# -gt 0 ]]; then
  case "$1" in
    dev|staging|prod)
      FLAVOR="$1"
      shift
      ;;
    stg)
      FLAVOR="staging"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      ;;
    *)
      usage
      die "Unsupported flavor: $1"
      ;;
  esac
fi

ENV_FILE="env/${FLAVOR}.env"
if [[ ! -f "$ENV_FILE" ]]; then
  ENV_FILE="env/${FLAVOR}.env.example"
  warn "Using $ENV_FILE because env/${FLAVOR}.env is not present."
fi

info "Running the $FLAVOR flavor..."
run_flutter run \
  --flavor "$FLAVOR" \
  --target "lib/main_${FLAVOR}.dart" \
  --dart-define-from-file="$ENV_FILE" \
  "$@"
