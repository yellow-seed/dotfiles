#!/usr/bin/env bats

@test "04-nix.sh exists" {
  [ -f "install/macos/04-nix.sh" ]
}

@test "04-nix.sh is executable" {
  [ -x "install/macos/04-nix.sh" ]
}

@test "04-nix.sh has proper error handling" {
  run grep "set -Eeuo pipefail" install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh references Determinate Systems installer URL" {
  run grep "install.determinate.systems/nix" install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh references nix flake check" {
  run grep "nix flake check" install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh references darwin-rebuild switch" {
  run grep "darwin-rebuild switch" install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh references first-time sudo nix-darwin activation" {
  run grep "sudo nix run nix-darwin#darwin-rebuild -- switch" install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh sources nix daemon profile after install" {
  run grep "nix-daemon.sh" install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh references Apple Silicon flake target" {
  run grep '\.#dotfiles"' install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh references Intel flake target" {
  run grep '\.#dotfiles-intel"' install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "nix flake does not force macOS hostname from flake target name" {
  run grep -R "networking.hostName" install/macos/nix
  [ "$status" -ne 0 ]
}

@test "nix-darwin systemPackages does not install git over Homebrew or system git" {
  run grep -Eq '^[[:space:]]+git[[:space:]]*$' install/macos/nix/darwin/default.nix
  [ "$status" -ne 0 ]
}

@test "04-nix.sh skips when DOTFILES_PROFILE is not set" {
  run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping nix-darwin"* ]]
}

@test "04-nix.sh skips when DOTFILES_PROFILE is work" {
  DOTFILES_PROFILE=work run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping nix-darwin"* ]]
}

@test "04-nix.sh skips when DOTFILES_PROFILE is common" {
  DOTFILES_PROFILE=common run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping nix-darwin"* ]]
}

@test "04-nix.sh supports DRY_RUN=true without errors" {
  DOTFILES_PROFILE=private DRY_RUN=true run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh DRY_RUN outputs dry run messages" {
  DOTFILES_PROFILE=private DRY_RUN=true run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN]"* ]]
}

@test "04-nix.sh DRY_RUN shows nix-darwin switch command" {
  DOTFILES_PROFILE=private DRY_RUN=true run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"switch --flake"* ]]
}

@test "04-nix.sh fails with a clear error when nix flake directory is missing" {
  cp install/macos/04-nix.sh "${BATS_TEST_TMPDIR}/04-nix.sh"

  DOTFILES_PROFILE=private DRY_RUN=true run bash "${BATS_TEST_TMPDIR}/04-nix.sh"

  [ "$status" -ne 0 ]
  [[ "$output" == *"expected Nix configuration directory"* ]]
}

@test "04-nix.sh non-interactive skip output is not labeled as DRY_RUN" {
  DOTFILES_PROFILE=private run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[SKIP]"* ]]
  [[ "$output" != *"[DRY RUN]"* ]]
}
