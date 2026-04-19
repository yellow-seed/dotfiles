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

@test "setup.sh has bootstrap_clone function" {
  run grep -q "bootstrap_clone" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh checks for install directory before running" {
  run grep -q 'SCRIPT_DIR}/install' "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh uses DOTFILES_REPO variable for clone URL" {
  run grep -q "DOTFILES_REPO" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh uses DOTFILES_CLONE_DIR variable for clone destination" {
  run grep -q "DOTFILES_CLONE_DIR" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh supports --profile option and exports DOTFILES_PROFILE" {
  run grep -q -- "--profile" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]

  run grep -q "export DOTFILES_PROFILE" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh bootstrap checks for git availability" {
  run grep -q "command -v git" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh triggers bootstrap when install directory is missing" {
  local temp_dir fake_bin clone_dir
  temp_dir="$(mktemp -d)"
  fake_bin="$(mktemp -d)"
  clone_dir="${temp_dir}/clone"  # 存在しないパスでブートストラップを誘発
  cp "${SETUP_SCRIPT}" "${temp_dir}/"

  # Mock git to fail after bootstrap message is printed
  printf '#!/usr/bin/env bash\nexit 1\n' >"${fake_bin}/git"
  chmod +x "${fake_bin}/git"

  run bash -c "DOTFILES_CLONE_DIR='${clone_dir}' PATH='${fake_bin}:${PATH}' bash '${temp_dir}/setup.sh'"

  rm -rf "${temp_dir}" "${fake_bin}"

  [ "$status" -ne 0 ]
  [[ "$output" =~ "Required scripts not found locally" ]]
}
