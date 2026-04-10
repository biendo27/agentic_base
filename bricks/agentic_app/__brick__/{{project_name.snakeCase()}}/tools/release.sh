#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

check_flutter

# TODO: Implement version bump logic
# Suggested steps:
#   1. Read current version from pubspec.yaml
#   2. Increment patch/minor/major based on $1 arg
#   3. Write new version back to pubspec.yaml
#   4. Commit and tag the release

warn "Release script not yet configured."
warn "Edit tools/release.sh to add version bump and tagging logic."
