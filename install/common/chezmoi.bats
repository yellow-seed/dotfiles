#!/usr/bin/env bats

@test "chezmoi installation script exists" {
  [ -f "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script is executable" {
  [ -x "install/common/chezmoi.sh" ]
}

@test "chezmoi installation script has proper error handling" {
  run grep "set -Eeuo pipefail" install/common/chezmoi.sh
  [ "$status" -eq 0 ]
}

@test "chezmoi installation script runs in dry-run mode" {
  run env DRY_RUN=true bash install/common/chezmoi.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "\\[DRY RUN\\]" ]]
}
