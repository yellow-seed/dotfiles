#!/usr/bin/env bats

SCRIPT_PATH="install/macos/02-brewfile.sh"

@test "brewfile installation script exists" {
  [ -f "${SCRIPT_PATH}" ]
}

@test "brewfile installation script is executable" {
  [ -x "${SCRIPT_PATH}" ]
}

@test "brewfile installation script runs without errors in dry-run mode" {
  run env DRY_RUN=true bash "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
}
