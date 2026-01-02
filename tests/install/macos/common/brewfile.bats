#!/usr/bin/env bats

setup() {
  # Source the script to make functions available for testing
  local script="install/macos/common/brewfile.sh"
  
  if [ ! -f "$script" ]; then
    echo "Error: required script '$script' not found." >&2
    return 1
  fi
  
  if [ ! -r "$script" ]; then
    echo "Error: required script '$script' is not readable." >&2
    return 1
  fi
  
  if ! source "$script"; then
    echo "Error: failed to source '$script'. Check for syntax errors or runtime issues." >&2
    return 1
  fi
  
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

@test "is_brew_exists returns 0 when brew is installed" {
  if command -v brew &>/dev/null; then
    run is_brew_exists
    [ "$status" -eq 0 ]
  else
    skip "brew not installed"
  fi
}

@test "is_brew_exists returns 1 when brew is not installed" {
  # Mock command to ensure function body executes
  function command() {
    if [[ "$1" == "-v" && "$2" == "brew" ]]; then
      return 1
    fi
    builtin command "$@"
  }
  export -f command
  
  run is_brew_exists
  [ "$status" -ne 0 ]
}

@test "install_brewfile exits when brew is not installed" {
  # Mock is_brew_exists to return false
  function is_brew_exists() {
    return 1
  }
  export -f is_brew_exists
  
  # Run in subshell to capture output
  run bash -c 'source install/macos/common/brewfile.sh; install_brewfile 2>&1 || true'
  [[ "$output" =~ "Homebrew is not installed" ]]
}

@test "install_brewfile checks for Brewfile existence" {
  # Mock brew to exist but Brewfile to not exist
  function is_brew_exists() {
    return 0
  }
  export -f is_brew_exists
  
  # Store original directory and run in temp directory
  local orig_dir="$PWD"
  cd "$TEST_TEMP_DIR"
  run bash -c "source '$orig_dir/install/macos/common/brewfile.sh'; install_brewfile 2>&1 || true"
  cd "$orig_dir"
  [[ "$output" =~ "Brewfile not found" ]]
}

@test "install_brewfile runs brew bundle when requirements are met" {
  if ! command -v brew &>/dev/null; then
    skip "brew not installed"
  fi
  
  # Create a test Brewfile in the script's directory
  local brewfile="install/macos/common/Brewfile"
  if [ ! -f "$brewfile" ]; then
    skip "Brewfile not found"
  fi
  
  # Mock brew bundle to avoid actual package installation
  function brew() {
    if [[ "$1" == "bundle" ]]; then
      echo "Mock: brew bundle executed with file: $3"
      return 0
    fi
    command brew "$@"
  }
  export -f brew
  
  run install_brewfile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Installing packages from Brewfile" ]] || [[ "$output" =~ "Mock: brew bundle" ]]
}

@test "main function calls install_brewfile" {
  # Mock install_brewfile to track if it was called
  function install_brewfile() {
    echo "install_brewfile was called"
  }
  export -f install_brewfile
  
  run main
  [ "$status" -eq 0 ]
  [[ "$output" =~ "install_brewfile was called" ]]
}
