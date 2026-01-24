#!/usr/bin/env bats

SCRIPT_PATH="install/macos/03-profile.sh"

@test "profile script exists" {
  [ -f "${SCRIPT_PATH}" ]
}

@test "profile script is executable" {
  [ -x "${SCRIPT_PATH}" ]
}

@test "detect_profile respects DOTFILES_PROFILE" {
  run env DOTFILES_PROFILE=work bash -c "source '${SCRIPT_PATH}'; detect_profile"
  [ "$status" -eq 0 ]
  [ "$output" = "work" ]
}

@test "get_profile_brewfile returns path for work profile" {
  run env DOTFILES_PROFILE=work bash -c "source '${SCRIPT_PATH}'; get_profile_brewfile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/install/macos/work/Brewfile" ]]
}

@test "profile script runs without errors in dry-run mode" {
  run env DOTFILES_PROFILE=work DRY_RUN=true bash "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\[DRY RUN\]" ]]
}
