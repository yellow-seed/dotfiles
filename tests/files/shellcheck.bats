#!/usr/bin/env bats

@test "all shell scripts pass ShellCheck validation" {
  # Skip if shellcheck is not available
  if ! command -v shellcheck &>/dev/null; then
    skip "ShellCheck is not installed"
  fi

  # Find all shell scripts and run ShellCheck
  run shellcheck \
    install/macos/common/brew.sh \
    install/macos/common/brewfile.sh \
    install/template.sh \
    setup.sh

  [ "$status" -eq 0 ]
}
