#!/usr/bin/env bats

@test "chezmoi installation script exists" {
  [ -f "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script is executable" {
  [ -x "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script uses strict mode" {
  run grep "set -Eeuo pipefail" install/common/chezmoi.sh
  [ "$status" -eq 0 ]
}

@test "chezmoi installation script runs in dry-run mode" {
  run env DRY_RUN=true GITHUB_USERNAME="test-user" bash install/common/chezmoi.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\\[DRY RUN\\]" ]]
  [[ "$output" =~ "test-user" ]]
}
