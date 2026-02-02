#!/usr/bin/env bats

@test "brew installation script exists" {
  [ -f "install/macos/02-brewfile.sh" ]
}

@test "brew installation script is executable" {
  [ -x "install/macos/02-brewfile.sh" ]
}

@test "brew installation script has proper error handling" {
  run grep "set -Eeuo pipefail" install/macos/02-brewfile.sh
  [ "$status" -eq 0 ]
}

@test "brew script runs without errors in dry-run mode" {
  run env DRY_RUN=true bash install/macos/02-brewfile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "[DRY RUN]" ]] || [[ "$output" =~ "Installing Homebrew" ]]
}
