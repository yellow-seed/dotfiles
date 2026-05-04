#!/usr/bin/env bats

@test "nix flake file exists" {
  [ -f "install/macos/nix/flake.nix" ]
}

@test "nix flake lock file exists" {
  [ -f "install/macos/nix/flake.lock" ]
}

@test "nix-darwin default module exists" {
  [ -f "install/macos/nix/darwin/default.nix" ]
}

@test "flake defines nix-darwin input" {
  run grep -Eq '^[[:space:]]*url = "github:LnL7/nix-darwin";$' install/macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake derives host names from base host" {
  run grep -Eq '^[[:space:]]*intelHost = "\$\{baseHost\}-intel";$' install/macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake defines Apple Silicon darwin configuration" {
  run grep -Eq '^[[:space:]]*"\$\{defaultHost\}" = mkDarwinSystem "aarch64-darwin";$' install/macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake defines Intel darwin configuration" {
  run grep -Eq '^[[:space:]]*"\$\{intelHost\}" = mkDarwinSystem "x86_64-darwin";$' install/macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "flake checks follow system-keyed output schema" {
  run grep -Eq '^[[:space:]]*aarch64-darwin\.default = self\.darwinConfigurations\."\$\{defaultHost\}"\.system;$' install/macos/nix/flake.nix
  [ "$status" -eq 0 ]
}

@test "darwin module configures required stateVersion" {
  run grep -Eq '^[[:space:]]*system\.stateVersion = 5;$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module disables nix when using Determinate installer" {
  run grep -Eq '^[[:space:]]*nix\.enable = false;$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module applies nix settings only when nix-darwin manages nix" {
  run grep -Eq '^[[:space:]]*nix\.settings = lib\.mkIf config\.nix\.enable \{$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "macOS docker test image installs nix" {
  run grep -Eq '^[[:space:]]*ENV USER=root$' docker/macos-test/Dockerfile
  [ "$status" -eq 0 ]
  run grep -Eq 'mkdir -m 0755 /nix' docker/macos-test/Dockerfile
  [ "$status" -eq 0 ]
  run grep -Eq 'https://nixos\.org/nix/install' docker/macos-test/Dockerfile
  [ "$status" -eq 0 ]
}

@test "macOS CI runs nix flake check" {
  run grep -Eq 'DeterminateSystems/nix-installer-action@main' .github/workflows/ci-macos.yml
  [ "$status" -eq 0 ]
  run grep -Eq '^[[:space:]]*run: nix --extra-experimental-features "nix-command flakes" flake check$' .github/workflows/ci-macos.yml
  [ "$status" -eq 0 ]
  run grep -Eq '^[[:space:]]*working-directory: install/macos/nix$' .github/workflows/ci-macos.yml
  [ "$status" -eq 0 ]
}

@test "darwin module disables startup chime" {
  run grep -Eq '^[[:space:]]*system\.startup\.chime = false;$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module hides dock automatically" {
  run grep -Eq '^[[:space:]]*system\.defaults\.dock\.autohide = true;$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module keeps only selected persistent dock apps" {
  run grep -Eq '^[[:space:]]*system\.defaults\.dock\.persistent-apps = \[$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
  run grep -Eq '^[[:space:]]*\{ app = "/System/Applications/Launchpad\.app"; \}$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
  run grep -Eq '^[[:space:]]*\{ app = "/System/Applications/App Store\.app"; \}$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
  run grep -Eq '^[[:space:]]*\{ app = "/System/Applications/System Settings\.app"; \}$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module keeps recent dock apps" {
  run grep -Eq '^[[:space:]]*system\.defaults\.dock\.show-recents = true;$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}

@test "darwin module disables automatic Japanese conversion" {
  run grep -Eq '^[[:space:]]*"com\.apple\.inputmethod\.Kotoeri" = \{$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
  run grep -Eq '^[[:space:]]*JIMPrefLiveConversionKey = false;$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
  run grep -Eq '^[[:space:]]*JIMPrefPredictiveCandidateKey = false;$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
  run grep -Eq '^[[:space:]]*JIMPrefConvertWithPunctuationKey = false;$' install/macos/nix/darwin/default.nix
  [ "$status" -eq 0 ]
}
