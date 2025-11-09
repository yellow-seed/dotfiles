#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../run_unit_test_common.sh
source "${SCRIPTS_ROOT}/run_unit_test_common.sh"

if ! command -v kcov &>/dev/null; then
    if command -v brew &>/dev/null; then
        echo "kcov not found. Installing via Homebrew..."
        if ! brew list kcov &>/dev/null; then
            brew install kcov || {
                echo "Warning: Failed to install kcov via Homebrew. Running tests without coverage." >&2
                run_tests_without_coverage
                exit 0
            }
        fi
    else
        echo "Warning: Homebrew not available. Running tests without coverage." >&2
        run_tests_without_coverage
        exit 0
    fi
fi

run_tests_with_kcov
