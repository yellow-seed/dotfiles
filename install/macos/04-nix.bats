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

@test "04-nix.sh supports DRY_RUN=true without errors" {
  DRY_RUN=true run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
}

@test "04-nix.sh DRY_RUN outputs dry run messages" {
  DRY_RUN=true run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN]"* ]]
}

@test "04-nix.sh DRY_RUN shows nix-darwin switch command" {
  DRY_RUN=true run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"switch --flake"* ]]
}

@test "04-nix.sh fails with a clear error when nix flake directory is missing" {
  cp install/macos/04-nix.sh "${BATS_TEST_TMPDIR}/04-nix.sh"

  DRY_RUN=true run bash "${BATS_TEST_TMPDIR}/04-nix.sh"

  [ "$status" -ne 0 ]
  [[ "$output" == *"expected Nix configuration directory"* ]]
}

@test "04-nix.sh non-interactive skip output is not labeled as DRY_RUN" {
  run bash install/macos/04-nix.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[SKIP]"* ]]
  [[ "$output" != *"[DRY RUN]"* ]]
}
