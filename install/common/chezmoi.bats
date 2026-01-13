#!/usr/bin/env bats

@test "chezmoi installation script exists" {
  [ -f "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script is executable" {
  [ -x "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script runs without errors" {
  run bash install/common/chezmoi.sh
  [ "$status" -eq 0 ]
}

@test "chezmoi command is available after installation" {
  run command -v chezmoi
  [ "$status" -eq 0 ]
}
