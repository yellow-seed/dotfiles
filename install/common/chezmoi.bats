#!/usr/bin/env bats

setup() {
  export PATH="/usr/bin:/bin"
  TEST_TEMP_HOME="$(mktemp -d)"
}

teardown() {
  [ -d "${TEST_TEMP_HOME}" ] && /bin/rm -rf "${TEST_TEMP_HOME}"
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

@test "setup_chezmoi_bin_dir creates bin directory and prepends PATH once" {
  export HOME="${TEST_TEMP_HOME}"
  export CHEZMOI_BIN_DIR="${HOME}/.local/bin"
  export PATH="/usr/bin:/bin"

  source install/common/chezmoi.sh

  setup_chezmoi_bin_dir
  [ -d "${CHEZMOI_BIN_DIR}" ]
  [ "${PATH}" = "${CHEZMOI_BIN_DIR}:/usr/bin:/bin" ]

  setup_chezmoi_bin_dir
  [ "${PATH}" = "${CHEZMOI_BIN_DIR}:/usr/bin:/bin" ]
}

@test "setup_chezmoi_bin_dir handles unset PATH" {
  export HOME="${TEST_TEMP_HOME}"
  export CHEZMOI_BIN_DIR="${HOME}/.local/bin"
  unset PATH

  source install/common/chezmoi.sh

  setup_chezmoi_bin_dir
  [ -d "${CHEZMOI_BIN_DIR}" ]
  [ "${PATH}" = "${CHEZMOI_BIN_DIR}" ]

  export PATH="/usr/bin:/bin"
}

@test "chezmoi installation script runs in dry-run mode without creating bin directory" {
  run env DRY_RUN=true HOME="${TEST_TEMP_HOME}" GITHUB_USERNAME="test-user" bash install/common/chezmoi.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN]"* ]]
  [[ "$output" =~ "test-user" ]]
  [ ! -d "${TEST_TEMP_HOME}/.local/bin" ]
}
