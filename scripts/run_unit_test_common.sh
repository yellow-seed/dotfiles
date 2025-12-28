#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

ensure_bats() {
    if ! command -v bats &>/dev/null; then
        echo "Error: bats is not installed. Please install bats before running the tests." >&2
        exit 1
    fi
}

run_bats_suite() {
    bats "${REPO_ROOT}/tests/install/"
    bats "${REPO_ROOT}/tests/files/"
    bats "${REPO_ROOT}/tests/scripts/"
}

run_tests() {
    ensure_bats
    run_bats_suite
}
