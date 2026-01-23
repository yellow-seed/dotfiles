#!/usr/bin/env bats

@test "03-profile script exists" {
  [ -f "install/macos/03-profile.sh" ]
}

@test "03-profile script is executable" {
  [ -x "install/macos/03-profile.sh" ]
}

@test "03-profile detects profile from DOTFILES_PROFILE" {
  run bash -c 'DOTFILES_PROFILE=work source install/macos/03-profile.sh; detect_profile'
  [ "$status" -eq 0 ]
  [ "$output" = "work" ]
}

@test "03-profile skips common profile" {
  run env DOTFILES_PROFILE=common bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Profile is common" ]]
}

@test "03-profile uses dry run for profile installs" {
  run env DOTFILES_PROFILE=work DRY_RUN=true bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
  [[ "$output" =~ "install/macos/work/Brewfile" ]]
}
