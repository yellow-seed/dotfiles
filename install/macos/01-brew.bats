#!/usr/bin/env bats

SCRIPT_PATH="install/macos/01-brew.sh"

@test "brew installation script exists" {
  [ -f "${SCRIPT_PATH}" ]
}

@test "brew installation script is executable" {
  [ -x "${SCRIPT_PATH}" ]
}

@test "brew installation script runs without errors in dry-run mode" {
  run env DRY_RUN=true bash "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
}
