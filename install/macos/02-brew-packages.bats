#!/usr/bin/env bats

setup() {
  SCRIPT_PATH="install/macos/02-brew-packages.sh"
}

@test "brew packages script exists" {
  [ -f "$SCRIPT_PATH" ]
}

@test "brew packages script is executable" {
  [ -x "$SCRIPT_PATH" ]
}

@test "brew packages script has proper error handling" {
  run grep "set -Eeuo pipefail" "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script does not reference external Brewfile" {
  run grep -E "brew bundle|Brewfile" "$SCRIPT_PATH"
  [ "$status" -ne 0 ]
}

@test "brew packages script defines taps array" {
  run grep -E '^[[:space:]]*(local[[:space:]]+(-a[[:space:]]+)?)?taps=\(' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines formulae array" {
  run grep -E '^[[:space:]]*(local[[:space:]]+(-a[[:space:]]+)?)?formulae=\(' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines casks array" {
  run grep -E '^[[:space:]]*(local[[:space:]]+(-a[[:space:]]+)?)?casks=\(' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script runs without errors in dry-run mode" {
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN]"* ]]
}

@test "brew packages dry-run output includes tap commands" {
  if ! command -v brew &>/dev/null; then
    skip "Requires Homebrew to be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Tapping Homebrew repositories"* ]]
  [[ "$output" == *"[DRY RUN] brew tap"* ]]
}

@test "brew packages dry-run output includes formulae commands" {
  if ! command -v brew &>/dev/null; then
    skip "Requires Homebrew to be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing Homebrew formulae"* ]]
  [[ "$output" == *"[DRY RUN] brew install"* ]]
}

@test "brew packages dry-run output includes cask commands" {
  if ! command -v brew &>/dev/null; then
    skip "Requires Homebrew to be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing Homebrew casks"* ]]
  [[ "$output" == *"[DRY RUN] brew install --cask"* ]]
}

@test "brew packages dry-run skips gracefully without Homebrew" {
  if command -v brew &>/dev/null; then
    skip "This test requires Homebrew to NOT be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN] Homebrew is not installed"* ]]
}
