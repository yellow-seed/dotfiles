#!/usr/bin/env bats

@test "nix flake file exists" {
  [ -f "macos/nix/flake.nix" ]
}

@test "nix-darwin default module exists" {
  [ -f "macos/nix/darwin/default.nix" ]
}

@test "flake defines nix-darwin input" {
  run grep -q 'nix-darwin' macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake defines darwinConfigurations" {
  run grep -q 'darwinConfigurations' macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "darwin module configures required stateVersion" {
  run grep -q 'system.stateVersion' macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module disables nix when using Determinate installer" {
  run grep -q 'nix.enable = false' macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}
