#!/usr/bin/env bats

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
  temp_home="$(mktemp -d)"
  export HOME="${temp_home}"
  export CHEZMOI_BIN_DIR="${HOME}/.local/bin"
  export PATH="/usr/bin:/bin"

  source install/common/chezmoi.sh

  setup_chezmoi_bin_dir
  [ -d "${CHEZMOI_BIN_DIR}" ]
  [ "${PATH}" = "${CHEZMOI_BIN_DIR}:/usr/bin:/bin" ]

  setup_chezmoi_bin_dir
  [ "${PATH}" = "${CHEZMOI_BIN_DIR}:/usr/bin:/bin" ]

  rm -rf "${temp_home}"
}

@test "chezmoi installation script runs in dry-run mode without creating bin directory" {
  temp_home="$(mktemp -d)"

  run env DRY_RUN=true HOME="${temp_home}" GITHUB_USERNAME="test-user" bash install/common/chezmoi.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\\[DRY RUN\\]" ]]
  [[ "$output" =~ "test-user" ]]
  [ ! -d "${temp_home}/.local/bin" ]

  rm -rf "${temp_home}"
}
