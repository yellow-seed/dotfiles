#!/usr/bin/env bats

@test "nix flake file exists" {
  [ -f "macos/nix/flake.nix" ]
}

@test "nix-darwin default module exists" {
  [ -f "macos/nix/darwin/default.nix" ]
}

@test "flake defines nix-darwin input" {
  run grep -Eq '^[[:space:]]*url = "github:LnL7/nix-darwin";$' macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake derives host names from base host" {
  run grep -Eq '^[[:space:]]*intelHost = "\$\{baseHost\}-intel";$' macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake defines Apple Silicon darwin configuration" {
  run grep -Eq '^[[:space:]]*"\$\{defaultHost\}" = mkDarwinSystem defaultHost "aarch64-darwin";$' macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake defines Intel darwin configuration" {
  run grep -Eq '^[[:space:]]*"\$\{intelHost\}" = mkDarwinSystem intelHost "x86_64-darwin";$' macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake checks follow system-keyed output schema" {
  run grep -Eq '^[[:space:]]*aarch64-darwin\.default = self\.darwinConfigurations\."\$\{defaultHost\}"\.system;$' macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "darwin module configures required stateVersion" {
  run grep -Eq '^[[:space:]]*system\.stateVersion = 5;$' macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module disables nix when using Determinate installer" {
  run grep -Eq '^[[:space:]]*nix\.enable = false;$' macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module applies nix settings only when nix-darwin manages nix" {
  run grep -Eq '^[[:space:]]*nix\.settings = lib\.mkIf config\.nix\.enable \{$' macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}
