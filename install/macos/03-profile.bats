#!/usr/bin/env bats

@test "profile detection honors DOTFILES_PROFILE override" {
  run bash -c 'DOTFILES_PROFILE=work source install/macos/03-profile.sh; detect_profile'
  [ "$status" -eq 0 ]
  [ "$output" = "work" ]
}

@test "profile Brewfile path resolves correctly" {
  run bash -c 'source install/macos/03-profile.sh; profile_brewfile_path work'
  [ "$status" -eq 0 ]
  [[ "$output" =~ /install/macos/work/Brewfile$ ]]
}

@test "profile script runs in dry-run mode" {
  run env DRY_RUN=true DOTFILES_PROFILE=work bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
}
