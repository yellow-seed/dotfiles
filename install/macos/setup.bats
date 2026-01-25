#!/usr/bin/env bats

@test "macOS setup script exists" {
  [ -f "install/macos/setup.sh" ]
}

@test "macOS setup script is executable" {
  [ -x "install/macos/setup.sh" ]
}

@test "macOS setup script runs without errors in dry-run mode" {
  DRY_RUN=true run bash install/macos/setup.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "macOS setup completed" ]]
}
