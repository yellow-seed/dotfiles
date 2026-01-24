#!/usr/bin/env bats

@test "brew installation script exists" {
  [ -f "install/macos/01-brew.sh" ]
}

@test "brew installation script is executable" {
  [ -x "install/macos/01-brew.sh" ]
}

@test "brew installation script runs without errors" {
  run env DRY_RUN=true bash install/macos/01-brew.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
}

@test "brew command is available after installation" {
  run command -v brew
  [ "$status" -eq 0 ]
}
