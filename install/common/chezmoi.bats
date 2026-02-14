#!/usr/bin/env bats

setup() {
  export TEMP_HOME
  TEMP_HOME="$(mktemp -d)"
}

teardown() {
  [ -d "${TEMP_HOME}" ] && rm -rf "${TEMP_HOME}"
}

@test "chezmoi installation script exists" {
  [ -f "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script is executable" {
  [ -x "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script uses strict mode" {
  run grep "set -Eeuo pipefail" install/common/chezmoi.sh
  [ "$status" -eq 0 ]
}

@test "setup_chezmoi_bin_dir creates bin dir and prepends PATH only once" {
  run env HOME="${TEMP_HOME}" PATH="/usr/bin" bash -c '
    source install/common/chezmoi.sh
    setup_chezmoi_bin_dir
    setup_chezmoi_bin_dir
    [ -d "${CHEZMOI_BIN_DIR}" ]
    [ "${PATH}" = "${CHEZMOI_BIN_DIR}:/usr/bin" ]
  '
  [ "$status" -eq 0 ]
}

@test "setup_chezmoi_bin_dir handles unset PATH" {
  run env -u PATH HOME="${TEMP_HOME}" bash -c '
    source install/common/chezmoi.sh
    setup_chezmoi_bin_dir
    [ -d "${CHEZMOI_BIN_DIR}" ]
    [[ "${PATH}" == "${CHEZMOI_BIN_DIR}:"* ]]
  '
  [ "$status" -eq 0 ]
}

@test "chezmoi installation script runs in dry-run mode without creating bin dir" {
  run env DRY_RUN=true HOME="${TEMP_HOME}" GITHUB_USERNAME="test-user" bash install/common/chezmoi.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\\[DRY RUN\\]" ]]
  [[ "$output" =~ "test-user" ]]
  [ ! -d "${TEMP_HOME}/.local/bin" ]
}
