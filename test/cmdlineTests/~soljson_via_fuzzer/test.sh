#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/common.sh
source "${REPO_ROOT}/scripts/common.sh"

SOLTMPDIR=$(mktemp -d -t "cmdline-test-soljson-via-fuzzer-XXXXXX")
cd "$SOLTMPDIR"

"$REPO_ROOT"/scripts/isolate_tests.py "$REPO_ROOT"/test/
"$REPO_ROOT"/scripts/isolate_tests.py "$REPO_ROOT"/docs/

find . -maxdepth 1 -name "*.sol" -print0 | xargs -0 -P 4 -n 50 "${SOLIDITY_BUILD_DIR}/test/tools/solfuzzer" --quiet --input-files
find . -maxdepth 1 -name "*.sol" -print0 | xargs -0 -P 4 -n 50 "${SOLIDITY_BUILD_DIR}/test/tools/solfuzzer" --without-optimizer --quiet --input-files

rm -r "$SOLTMPDIR"
