#!/usr/bin/env bats

@test "macos setup script can be invoked" {
  run bash -c 'DRY_RUN=true bash install/macos/setup.sh'
  [ "$status" -eq 0 ]
}
