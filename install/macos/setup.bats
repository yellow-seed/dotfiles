#!/usr/bin/env bats

# Note: Execution tests are performed in individual step tests (01-brew.bats, 02-brew-packages.bats, 03-profile.bats)
# This file only tests the structure of setup.sh to avoid duplicate test runs with kcov

@test "macOS setup script exists" {
  [ -f "install/macos/setup.sh" ]
}

@test "macOS setup script is executable" {
  [ -x "install/macos/setup.sh" ]
}

@test "macOS setup script has proper error handling" {
  run grep "set -Eeuo pipefail" install/macos/setup.sh
  [ "$status" -eq 0 ]
}

@test "macOS setup script calls all step scripts" {
  run grep "01-brew.sh" install/macos/setup.sh
  [ "$status" -eq 0 ]
  run grep "02-brew-packages.sh" install/macos/setup.sh
  [ "$status" -eq 0 ]
  run grep "03-profile.sh" install/macos/setup.sh
  [ "$status" -eq 0 ]
}

@test "macOS setup script exports DRY_RUN for child processes" {
  run grep "export DRY_RUN" install/macos/setup.sh
  [ "$status" -eq 0 ]
}
