#!/usr/bin/env bats

setup() {
  SETUP_SCRIPT="${BATS_TEST_DIRNAME}/../../setup.sh"
}

@test "setup.sh exists and is executable" {
  [ -f "${SETUP_SCRIPT}" ]
  [ -x "${SETUP_SCRIPT}" ]
}

@test "setup.sh detects OS using uname" {
  run grep -q "uname" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh handles macOS and Linux" {
  run grep -q "Darwin" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]

  run grep -q "Linux" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh delegates to OS-specific setup scripts" {
  run grep -q "install/macos/setup.sh" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]

  run grep -q "install/ubuntu/setup.sh" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh runs shared chezmoi setup" {
  run grep -q "install/common/chezmoi.sh" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}
