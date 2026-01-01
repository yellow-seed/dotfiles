#!/usr/bin/env bats

setup() {
  # Source the script to make functions available for testing
  source install/macos/common/brew.sh
}

@test "brew installation script exists" {
  [ -f "install/macos/common/brew.sh" ]
}

@test "brew installation script is executable" {
  [ -x "install/macos/common/brew.sh" ]
}

@test "is_brew_exists function is defined" {
  run type is_brew_exists
  [ "$status" -eq 0 ]
  [[ "$output" =~ "is_brew_exists is a function" ]]
}

@test "is_brew_exists returns 0 when brew is installed" {
  if command -v brew &>/dev/null; then
    run is_brew_exists
    [ "$status" -eq 0 ]
  else
    skip "brew not installed"
  fi
}

@test "install_brew function is defined" {
  run type install_brew
  [ "$status" -eq 0 ]
  [[ "$output" =~ "install_brew is a function" ]]
}

@test "install_brew detects when brew is already installed" {
  if command -v brew &>/dev/null; then
    run install_brew
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Homebrew is already installed" ]]
  else
    skip "brew not installed - cannot test detection"
  fi
}

@test "main function is defined" {
  run type main
  [ "$status" -eq 0 ]
  [[ "$output" =~ "main is a function" ]]
}

@test "main function calls install_brew" {
  # Test by checking if main function exists and is callable
  # Actual execution is tested in E2E test below
  run declare -f main
  [ "$status" -eq 0 ]
  [[ "$output" =~ "install_brew" ]]
}

# E2E test: Run script as it would be executed normally
@test "brew installation script runs without errors (E2E)" {
  run bash install/macos/common/brew.sh
  [ "$status" -eq 0 ]
}

@test "brew command is available after installation" {
  run command -v brew
  [ "$status" -eq 0 ]
}
