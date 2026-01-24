#!/usr/bin/env bats

@test "macos setup script exists" {
  [ -f "install/macos/setup.sh" ]
}

@test "macos setup script is executable" {
  [ -x "install/macos/setup.sh" ]
}

@test "macos setup script runs in dry-run mode" {
  run bash -c 'DRY_RUN=true bash install/macos/setup.sh >"$BATS_TEST_TMPDIR/output"; grep -q "\\[DRY RUN\\]" "$BATS_TEST_TMPDIR/output"'
  [ "$status" -eq 0 ]
}
