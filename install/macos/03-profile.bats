#!/usr/bin/env bats

@test "profile installation script exists" {
  [ -f "install/macos/03-profile.sh" ]
}

@test "profile installation script is executable" {
  [ -x "install/macos/03-profile.sh" ]
}

@test "profile installation script has proper error handling" {
  run grep "set -Eeuo pipefail" install/macos/03-profile.sh
  [ "$status" -eq 0 ]
}

@test "profile script skips common profile in dry-run mode" {
  run env DOTFILES_PROFILE=common DRY_RUN=true bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Profile is common" ]]
}

@test "profile script runs work profile in dry-run mode" {
  run env DOTFILES_PROFILE=work DRY_RUN=true bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "[DRY RUN] Would install work-specific packages" ]]
}
