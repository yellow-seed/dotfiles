#!/usr/bin/env bats

@test "macos setup script exists" {
  [ -f "install/macos/setup.sh" ]
}

@test "macos setup script is executable" {
  [ -x "install/macos/setup.sh" ]
}

@test "macos setup script runs in dry-run mode" {
  run env DRY_RUN=true bash install/macos/setup.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
}
