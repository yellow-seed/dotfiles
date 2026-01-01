#!/usr/bin/env bats

setup() {
  # Source the script to make functions available for testing
  source install/macos/common/brewfile.sh

  # Create temporary directory for testing
  TEST_TEMP_DIR="$(mktemp -d)"
}

teardown() {
  # Clean up temporary directory
  [ -d "$TEST_TEMP_DIR" ] && rm -rf "$TEST_TEMP_DIR"
}

@test "brewfile installation script exists" {
  [ -f "install/macos/common/brewfile.sh" ]
}

@test "brewfile installation script is executable" {
  [ -x "install/macos/common/brewfile.sh" ]
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

@test "install_brewfile function is defined" {
  run type install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "install_brewfile is a function" ]]
}

@test "install_brewfile function requires brew to be installed" {
  # Check function definition contains brew check logic
  run declare -f install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "is_brew_exists" ]]
}

@test "install_brewfile checks for Brewfile existence" {
  # Verify the function logic checks for Brewfile
  run declare -f install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Brewfile" ]]
}

@test "install_brewfile finds script directory correctly" {
  # Verify the function uses BASH_SOURCE to find script directory
  run declare -f install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "BASH_SOURCE" ]]
  [[ "$output" =~ "dirname" ]]
}

@test "install_brewfile constructs correct Brewfile path" {
  # Verify the function constructs path to Brewfile in script directory
  run declare -f install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ 'brewfile="${script_dir}/Brewfile"' ]]
}

@test "install_brewfile includes error message for missing brew" {
  # Verify error message exists for missing brew
  run declare -f install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Homebrew is not installed" ]]
}

@test "install_brewfile includes error message for missing Brewfile" {
  # Verify error message exists for missing Brewfile
  run declare -f install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Brewfile not found" ]]
}

@test "install_brewfile uses brew bundle command" {
  # Verify the function uses brew bundle
  run declare -f install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "brew bundle" ]]
}

@test "main function is defined" {
  run type main
  [ "$status" -eq 0 ]
  [[ "$output" =~ "main is a function" ]]
}

@test "main function calls install_brewfile" {
  run declare -f main
  [ "$status" -eq 0 ]
  [[ "$output" =~ "install_brewfile" ]]
}
