#!/usr/bin/env bats

setup() {
  # Create a temporary directory for test outputs
  TEST_TEMP_DIR="$(mktemp -d)"
  SCRIPT_PATH="scripts/macos/brew-dump-explicit.sh"
}

teardown() {
  # Clean up temporary directory
  rm -rf "$TEST_TEMP_DIR"
}

@test "brew-dump-explicit script exists" {
  [ -f "$SCRIPT_PATH" ]
}

@test "brew-dump-explicit script is executable" {
  [ -x "$SCRIPT_PATH" ]
}

# Note: intel macは考慮しない
@test "brew-dump-explicit script has valid shebang" {
  run head -n 1 "$SCRIPT_PATH"
  [[ "$output" == "#!/opt/homebrew/bin/bash" ]]
}

@test "brew-dump-explicit creates output file with default name" {
  skip "Requires brew to be installed"
  cd "$TEST_TEMP_DIR"
  run bash "${OLDPWD}/${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [ -f "Brewfile" ]
}

@test "brew-dump-explicit creates output file with custom name" {
  skip "Requires brew to be installed"
  cd "$TEST_TEMP_DIR"
  run bash "${OLDPWD}/${SCRIPT_PATH}" "CustomBrewfile"
  [ "$status" -eq 0 ]
  [ -f "CustomBrewfile" ]
}

@test "brew-dump-explicit output contains Taps section" {
  skip "Requires brew to be installed"
  cd "$TEST_TEMP_DIR"
  bash "${OLDPWD}/${SCRIPT_PATH}" "test_output"
  run grep "# Taps" "test_output"
  [ "$status" -eq 0 ]
}

@test "brew-dump-explicit output contains Formulae section" {
  skip "Requires brew to be installed"
  cd "$TEST_TEMP_DIR"
  bash "${OLDPWD}/${SCRIPT_PATH}" "test_output"
  run grep "# Formulae (explicitly installed)" "test_output"
  [ "$status" -eq 0 ]
}

@test "brew-dump-explicit output contains Casks section" {
  skip "Requires brew to be installed"
  cd "$TEST_TEMP_DIR"
  bash "${OLDPWD}/${SCRIPT_PATH}" "test_output"
  run grep "# Casks" "test_output"
  [ "$status" -eq 0 ]
}

@test "brew-dump-explicit output uses correct tap format" {
  skip "Requires brew to be installed and at least one tap"
  cd "$TEST_TEMP_DIR"
  bash "${OLDPWD}/${SCRIPT_PATH}" "test_output"
  # Check if tap lines follow the format: tap "name"
  run grep -E '^tap ".*"$' "test_output"
  [ "$status" -eq 0 ]
}

@test "brew-dump-explicit output uses correct brew format" {
  skip "Requires brew to be installed and at least one formula"
  cd "$TEST_TEMP_DIR"
  bash "${OLDPWD}/${SCRIPT_PATH}" "test_output"
  # Check if brew lines follow the format: brew "name"
  run grep -E '^brew ".*"$' "test_output"
  [ "$status" -eq 0 ]
}

@test "brew-dump-explicit output uses correct cask format" {
  skip "Requires brew to be installed and at least one cask"
  cd "$TEST_TEMP_DIR"
  bash "${OLDPWD}/${SCRIPT_PATH}" "test_output"
  # Check if cask lines follow the format: cask "name"
  run grep -E '^cask ".*"$' "test_output"
  [ "$status" -eq 0 ]
}

@test "brew-dump-explicit can be sourced as a function" {
  run bash -c "source '${SCRIPT_PATH}' && type brew-dump-explicit"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "brew-dump-explicit is a function" ]]
}

@test "brew-dump-explicit handles directory path by appending Brewfile" {
  skip "Requires brew to be installed"
  mkdir -p "$TEST_TEMP_DIR/subdir"
  cd "$TEST_TEMP_DIR"
  bash "${OLDPWD}/${SCRIPT_PATH}" "subdir"
  [ -f "subdir/Brewfile" ]
}

@test "brew-dump-explicit preserves comments from existing Brewfile" {
  skip "Requires brew to be installed"
  cd "$TEST_TEMP_DIR"

  # Create a Brewfile with comments
  cat >"Brewfile" <<'EOF'
# Taps
tap "homebrew/core"

# Formulae (explicitly installed)
# This is a comment for git
brew "git"

# Casks
# This is a comment for firefox
cask "firefox"
EOF

  # Run the script
  bash "${OLDPWD}/${SCRIPT_PATH}" "Brewfile"

  # Check if comments are preserved (at least the structure should exist)
  [ -f "Brewfile" ]
  run grep "# Taps" "Brewfile"
  [ "$status" -eq 0 ]
}

@test "brew-dump-explicit preserves mas entries from existing Brewfile" {
  skip "Requires brew to be installed"
  cd "$TEST_TEMP_DIR"

  # Create a Brewfile with mas entries
  cat >"Brewfile" <<'EOF'
# Taps
tap "homebrew/core"

# Formulae (explicitly installed)
brew "git"

# Casks
cask "firefox"

# Mac App Store
mas "Xcode", id: 497799835
mas "Pages", id: 409201541
EOF

  # Run the script
  bash "${OLDPWD}/${SCRIPT_PATH}" "Brewfile"

  # Check if mas section is preserved
  run grep "# Mac App Store" "Brewfile"
  [ "$status" -eq 0 ]
  run grep '^mas "Xcode"' "Brewfile"
  [ "$status" -eq 0 ]
}

@test "brew-dump-explicit preserves go entries from existing Brewfile" {
  skip "Requires brew to be installed"
  cd "$TEST_TEMP_DIR"

  # Create a Brewfile with go entries
  cat >"Brewfile" <<'EOF'
# Taps
tap "homebrew/core"

# Formulae (explicitly installed)
brew "git"

# Casks
cask "firefox"

# Go packages
go "github.com/user/package"
EOF

  # Run the script
  bash "${OLDPWD}/${SCRIPT_PATH}" "Brewfile"

  # Check if go section is preserved
  run grep "# Go packages" "Brewfile"
  [ "$status" -eq 0 ]
  run grep '^go "github.com/user/package"' "Brewfile"
  [ "$status" -eq 0 ]
}
