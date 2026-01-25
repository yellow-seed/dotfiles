#!/usr/bin/env bats

setup() {
  SETUP_SCRIPT="${BATS_TEST_DIRNAME}/../../setup.sh"
}

@test "setup.sh exists and is executable" {
  [ -f "${SETUP_SCRIPT}" ]
  [ -x "${SETUP_SCRIPT}" ]
}

@test "ubuntu setup script exists and is executable" {
  [ -f "${BATS_TEST_DIRNAME}/../../install/ubuntu/setup.sh" ]
  [ -x "${BATS_TEST_DIRNAME}/../../install/ubuntu/setup.sh" ]
}

@test "setup.sh delegates to OS-specific and chezmoi scripts" {
  run grep "install/macos/setup.sh" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
  run grep "install/ubuntu/setup.sh" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
  run grep "install/common/chezmoi.sh" "${SETUP_SCRIPT}"
  [ "$status" -eq 0 ]
}

@test "setup.sh runs macOS delegation" {
  local temp_dir
  temp_dir="$(mktemp -d)"

  cp "${SETUP_SCRIPT}" "${temp_dir}/setup.sh"
  mkdir -p "${temp_dir}/install/macos" "${temp_dir}/install/ubuntu" "${temp_dir}/install/common" "${temp_dir}/bin"

  cat >"${temp_dir}/install/macos/setup.sh" <<'EOF'
#!/usr/bin/env bash
echo "macOS setup called"
EOF
  cat >"${temp_dir}/install/ubuntu/setup.sh" <<'EOF'
#!/usr/bin/env bash
echo "Linux setup called"
EOF
  cat >"${temp_dir}/install/common/chezmoi.sh" <<'EOF'
#!/usr/bin/env bash
echo "chezmoi setup called"
EOF
  cat >"${temp_dir}/bin/uname" <<'EOF'
#!/usr/bin/env bash
echo "Darwin"
EOF

  chmod +x "${temp_dir}/setup.sh" "${temp_dir}/install/macos/setup.sh" \
    "${temp_dir}/install/ubuntu/setup.sh" "${temp_dir}/install/common/chezmoi.sh" \
    "${temp_dir}/bin/uname"

  run env PATH="${temp_dir}/bin:${PATH}" bash "${temp_dir}/setup.sh"

  rm -rf "${temp_dir}"

  [ "$status" -eq 0 ]
  [[ "${output}" == *"Detected macOS environment"* ]]
  [[ "${output}" == *"macOS setup called"* ]]
  [[ "${output}" == *"chezmoi setup called"* ]]
}

@test "setup.sh runs Linux delegation" {
  local temp_dir
  temp_dir="$(mktemp -d)"

  cp "${SETUP_SCRIPT}" "${temp_dir}/setup.sh"
  mkdir -p "${temp_dir}/install/macos" "${temp_dir}/install/ubuntu" "${temp_dir}/install/common" "${temp_dir}/bin"

  cat >"${temp_dir}/install/macos/setup.sh" <<'EOF'
#!/usr/bin/env bash
echo "macOS setup called"
EOF
  cat >"${temp_dir}/install/ubuntu/setup.sh" <<'EOF'
#!/usr/bin/env bash
echo "Linux setup called"
EOF
  cat >"${temp_dir}/install/common/chezmoi.sh" <<'EOF'
#!/usr/bin/env bash
echo "chezmoi setup called"
EOF
  cat >"${temp_dir}/bin/uname" <<'EOF'
#!/usr/bin/env bash
echo "Linux"
EOF

  chmod +x "${temp_dir}/setup.sh" "${temp_dir}/install/macos/setup.sh" \
    "${temp_dir}/install/ubuntu/setup.sh" "${temp_dir}/install/common/chezmoi.sh" \
    "${temp_dir}/bin/uname"

  run env PATH="${temp_dir}/bin:${PATH}" bash "${temp_dir}/setup.sh"

  rm -rf "${temp_dir}"

  [ "$status" -eq 0 ]
  [[ "${output}" == *"Detected Linux environment"* ]]
  [[ "${output}" == *"Linux setup called"* ]]
  [[ "${output}" == *"chezmoi setup called"* ]]
}

@test "setup.sh fails on unsupported OS" {
  local temp_dir
  temp_dir="$(mktemp -d)"

  cp "${SETUP_SCRIPT}" "${temp_dir}/setup.sh"
  mkdir -p "${temp_dir}/install/macos" "${temp_dir}/install/ubuntu" "${temp_dir}/install/common" "${temp_dir}/bin"

  cat >"${temp_dir}/install/macos/setup.sh" <<'EOF'
#!/usr/bin/env bash
echo "macOS setup called"
EOF
  cat >"${temp_dir}/install/ubuntu/setup.sh" <<'EOF'
#!/usr/bin/env bash
echo "Linux setup called"
EOF
  cat >"${temp_dir}/install/common/chezmoi.sh" <<'EOF'
#!/usr/bin/env bash
echo "chezmoi setup called"
EOF
  cat >"${temp_dir}/bin/uname" <<'EOF'
#!/usr/bin/env bash
echo "Windows"
EOF

  chmod +x "${temp_dir}/setup.sh" "${temp_dir}/install/macos/setup.sh" \
    "${temp_dir}/install/ubuntu/setup.sh" "${temp_dir}/install/common/chezmoi.sh" \
    "${temp_dir}/bin/uname"

  run env PATH="${temp_dir}/bin:${PATH}" bash "${temp_dir}/setup.sh"

  rm -rf "${temp_dir}"

  [ "$status" -eq 1 ]
  [[ "${output}" == *"Unsupported OS"* ]]
}
