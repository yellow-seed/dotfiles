#!/usr/bin/env bats

@test "macOS setup script exists" {
  [ -f "install/macos/setup.sh" ]
}

@test "macOS setup script is executable" {
  [ -x "install/macos/setup.sh" ]
}

@test "macOS setup script supports dry run" {
  run env DRY_RUN=true bash install/macos/setup.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
}
