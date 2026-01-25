#!/usr/bin/env bats

@test "brewfile installation script exists" {
  [ -f "install/macos/02-brewfile.sh" ]
}

@test "brewfile installation script is executable" {
  [ -x "install/macos/02-brewfile.sh" ]
}

@test "brewfile script runs without errors in dry-run mode" {
  DRY_RUN=true run bash install/macos/02-brewfile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\\[DRY RUN\\]" ]] || [[ "$output" =~ "Installing packages" ]]
}
