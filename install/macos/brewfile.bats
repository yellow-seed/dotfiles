#!/usr/bin/env bats

@test "brewfile installation script exists" {
  [ -f "install/macos/brewfile.sh" ]
}

@test "brewfile installation script is executable" {
  [ -x "install/macos/brewfile.sh" ]
}

@test "brewfile script supports dry run" {
  run env DRY_RUN=true bash install/macos/brewfile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
}

# Actual installation tests take time, so only basic operation checks are performed
@test "brewfile script checks for brew command" {
  skip "Requires actual chezmoi setup"
  # This test should be executed in E2E tests
}
