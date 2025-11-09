#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../run_unit_test_common.sh
source "${SCRIPTS_ROOT}/run_unit_test_common.sh"

echo "kcov is not installed on ubuntu-latest GitHub runners. Running tests without coverage."
run_tests_without_coverage
