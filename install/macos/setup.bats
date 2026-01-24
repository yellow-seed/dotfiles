#!/usr/bin/env bats

SCRIPT_PATH="install/macos/setup.sh"

@test "setup script exists" {
  [ -f "${SCRIPT_PATH}" ]
}

@test "setup script is executable" {
  [ -x "${SCRIPT_PATH}" ]
}

@test "setup script runs without errors in dry-run mode" {
  run env DRY_RUN=true bash "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "macOS setup completed." ]]
}
