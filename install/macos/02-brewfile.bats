#!/usr/bin/env bats

@test "brewfile installation script exists" {
  [ -f "install/macos/02-brewfile.sh" ]
}

@test "brewfile installation script is executable" {
  [ -x "install/macos/02-brewfile.sh" ]
}

@test "brewfile installation script has proper error handling" {
  run grep "set -Eeuo pipefail" install/macos/02-brewfile.sh
  [ "$status" -eq 0 ]
}

@test "brewfile installation script defines package arrays" {
  run rg -n "^TAPS=\(" install/macos/02-brewfile.sh
  [ "$status" -eq 0 ]
  run rg -n "^FORMULAE=\(" install/macos/02-brewfile.sh
  [ "$status" -eq 0 ]
  run rg -n "^CASKS=\(" install/macos/02-brewfile.sh
  [ "$status" -eq 0 ]
}

@test "brewfile installation script does not use brew bundle" {
  run rg -n "brew bundle" install/macos/02-brewfile.sh
  [ "$status" -ne 0 ]
}

@test "brewfile script runs without errors in dry-run mode" {
  run env DRY_RUN=true bash install/macos/02-brewfile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "[DRY RUN]" ]]
}
