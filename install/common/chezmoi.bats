#!/usr/bin/env bats

# Note: These tests are skipped as chezmoi.sh implementation is pending
# chezmoi is an OS-agnostic tool, so it belongs in install/common/

@test "chezmoi installation script exists" {
  skip "chezmoi.sh implementation is pending"
  [ -f "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script is executable" {
  skip "chezmoi.sh implementation is pending"
  [ -x "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script runs without errors" {
  skip "chezmoi.sh implementation is pending"
  run bash install/common/chezmoi.sh
  [ "$status" -eq 0 ]
}

@test "chezmoi command is available after installation" {
  skip "chezmoi may not be pre-installed in all CI environments"
  # This test checks if chezmoi is already installed in the CI environment
  run command -v chezmoi
  [ "$status" -eq 0 ]
}
