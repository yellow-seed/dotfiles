#!/usr/bin/env bats

@test "brew installation script exists" {
  [ -f "install/macos/common/brew.sh" ]
}

@test "brew installation script is executable" {
  [ -x "install/macos/common/brew.sh" ]
}

@test "brew installation script runs without errors" {
  run bash install/macos/common/brew.sh
  [ "$status" -eq 0 ]
}

@test "brew command is available after installation" {
  run command -v brew
  [ "$status" -eq 0 ]
}
