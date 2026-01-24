#!/usr/bin/env bats

@test "brew installation script exists" {
  [ -f "install/macos/01-brew.sh" ]
}

@test "brew installation script is executable" {
  [ -x "install/macos/01-brew.sh" ]
}

@test "brew installation script runs without errors" {
  run bash -c 'DRY_RUN=true bash install/macos/01-brew.sh >"$BATS_TEST_TMPDIR/output"; grep -q "\\[DRY RUN\\]" "$BATS_TEST_TMPDIR/output"'
  [ "$status" -eq 0 ]
}

@test "brew command is available after installation" {
  skip "Requires actual Homebrew installation"
}
