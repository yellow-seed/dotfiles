#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../run_unit_test_common.sh
source "${SCRIPTS_ROOT}/run_unit_test_common.sh"

if ! command -v kcov &>/dev/null; then
    echo "kcov not found. Installing via apt..."
    # Check if we have sudo access (CI environment)
    if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        sudo apt-get update && sudo apt-get install -y kcov || {
            echo "Warning: Failed to install kcov via apt. Running tests without coverage." >&2
            run_tests_without_coverage
            exit 0
        }
    else
        echo "Warning: Cannot install kcov without sudo. Running tests without coverage." >&2
        run_tests_without_coverage
        exit 0
    fi
fi

run_tests_with_kcov
