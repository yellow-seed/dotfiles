#!/usr/bin/env bats

@test "all shell scripts pass ShellCheck validation" {
  # Skip if shellcheck is not available
  if ! command -v shellcheck &>/dev/null; then
    skip "ShellCheck is not installed"
  fi

  # Find all shell scripts and run ShellCheck
  run shellcheck \
    install/macos/01-brew.sh \
    install/macos/02-brewfile.sh \
    install/macos/03-profile.sh \
    install/macos/setup.sh \
    install/macos/brew-dump-explicit.sh \
    install/template.sh \
    setup.sh

  [ "$status" -eq 0 ]
}
