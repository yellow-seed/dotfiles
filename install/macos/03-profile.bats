#!/usr/bin/env bats

setup() {
  TEST_BIN_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_BIN_DIR"
}

write_brew_stub() {
  cat >"$TEST_BIN_DIR/brew" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [ "$1" = "list" ] && [ "$2" = "--formula" ]; then
  exit 0
fi

if [ "$1" = "list" ] && [ "$2" = "--cask" ]; then
  exit 0
fi

if [ "$1" = "tap" ]; then
  echo "TAP $2"
  exit 0
fi

if [ "$1" = "install" ]; then
  echo "INSTALL $*"
  exit 0
fi

echo "UNEXPECTED: $*" >&2
exit 2
EOF

  chmod +x "$TEST_BIN_DIR/brew"
}

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

@test "profile installation script does not use brew bundle" {
  run grep -E "brew bundle|Brewfile" install/macos/03-profile.sh
  [ "$status" -ne 0 ]
}

@test "private profile packages script exists" {
  [ -f "install/macos/private/brew-packages.sh" ]
}

@test "work profile packages script exists" {
  [ -f "install/macos/work/brew-packages.sh" ]
}

@test "extension profile packages script exists" {
  [ -f "install/macos/extension/brew-packages.sh" ]
}

@test "profile Brewfiles are removed after script migration" {
  [ ! -f "install/macos/private/Brewfile" ]
  [ ! -f "install/macos/work/Brewfile" ]
}

@test "profile script skips common profile in dry-run mode" {
  run env DOTFILES_PROFILE=common DRY_RUN=true bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Profile is common" ]]
}

@test "profile script runs work profile in dry-run mode" {
  run env DOTFILES_PROFILE=work DRY_RUN=true bash install/macos/03-profile.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Installing work-specific packages" ]]
}

@test "profile script accepts --profile option" {
  run env DRY_RUN=true bash install/macos/03-profile.sh --profile work
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Installing work-specific packages" ]]
}

@test "profile script prioritizes --profile over DOTFILES_PROFILE env" {
  run env DOTFILES_PROFILE=common DRY_RUN=true bash install/macos/03-profile.sh --profile work
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Installing work-specific packages" ]]
}

@test "private profile script runs in dry-run mode" {
  write_brew_stub

  run env PATH="$TEST_BIN_DIR:$PATH" DRY_RUN=true bash install/macos/private/brew-packages.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN]"* ]]
}

@test "private profile installs opencode from anomalyco tap" {
  write_brew_stub

  run env PATH="$TEST_BIN_DIR:$PATH" DRY_RUN=true bash install/macos/private/brew-packages.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN] brew tap anomalyco/tap"* ]]
  [[ "$output" == *"[DRY RUN] brew install anomalyco/tap/opencode"* ]]
}

@test "work profile script runs in dry-run mode" {
  run env DRY_RUN=true bash install/macos/work/brew-packages.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "No work-specific packages configured" ]]
}

@test "extension profile script runs in dry-run mode" {
  run env DRY_RUN=true bash install/macos/03-profile.sh --profile extension
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Installing extension-specific packages" ]]
  [[ "$output" =~ "No extension packages configured" ]]
}

@test "profile script fails for unknown option" {
  run bash install/macos/03-profile.sh --unknown
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unknown option" ]]
}
