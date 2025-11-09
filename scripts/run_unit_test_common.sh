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
}

run_tests_without_coverage() {
    ensure_bats
    run_bats_suite
}

run_tests_with_kcov() {
    ensure_bats

    if ! command -v kcov &>/dev/null; then
        echo "Error: kcov is not installed but coverage execution was requested." >&2
        exit 1
    fi

    local coverage_dir="${REPO_ROOT}/coverage"
    mkdir -p "${coverage_dir}"

    kcov --clean --include-path="${REPO_ROOT}/install" \
        "${coverage_dir}" \
        bats "${REPO_ROOT}/tests/install/"

    bats "${REPO_ROOT}/tests/files/"
}
