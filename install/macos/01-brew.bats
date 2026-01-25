#!/usr/bin/env bats

setup() {
  export DRY_RUN=true
}

@test "brew installation script exists" {
  [ -f "install/macos/01-brew.sh" ]
}

@test "brew installation script is executable" {
  [ -x "install/macos/01-brew.sh" ]
}

@test "brew installation script runs without errors in dry-run mode" {
  DRY_RUN=true run bash install/macos/01-brew.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\\[DRY RUN\\]" ]] || [[ "$output" =~ "already installed" ]]
}
