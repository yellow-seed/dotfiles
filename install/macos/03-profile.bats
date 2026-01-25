#!/usr/bin/env bats

@test "profile installation script exists" {
  [ -f "install/macos/03-profile.sh" ]
}

@test "profile installation script is executable" {
  [ -x "install/macos/03-profile.sh" ]
}

@test "profile script skips common profile in dry-run mode" {
  DOTFILES_PROFILE=common DRY_RUN=true run bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Profile is common" ]]
}

@test "profile script runs work profile in dry-run mode" {
  DOTFILES_PROFILE=work DRY_RUN=true run bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\] Would install work-specific packages" ]]
}
