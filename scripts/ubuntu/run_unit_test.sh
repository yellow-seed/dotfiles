#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../run_unit_test_common.sh
source "${SCRIPTS_ROOT}/run_unit_test_common.sh"

if ! command -v kcov &>/dev/null; then
    echo "Warning: kcov is not installed. Running tests without coverage." >&2
    echo "To enable coverage on Ubuntu, install kcov from source:" >&2
    echo "  https://github.com/SimonKagstrom/kcov" >&2
    run_tests_without_coverage
    exit 0
fi

run_tests_with_kcov
