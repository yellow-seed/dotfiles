#!/usr/bin/env bats

@test "brew installation script exists" {
  [ -f "install/macos/01-brew.sh" ]
}

@test "brew installation script is executable" {
  [ -x "install/macos/01-brew.sh" ]
}

@test "brew installation script has proper error handling" {
  run grep "set -Eeuo pipefail" install/macos/01-brew.sh
  [ "$status" -eq 0 ]
}

@test "brew installation script runs without errors in dry-run mode" {
  run env DRY_RUN=true bash install/macos/01-brew.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "[DRY RUN]" ]] || [[ "$output" =~ "already installed" ]]
}
