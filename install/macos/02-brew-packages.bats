#!/usr/bin/env bats

setup() {
  SCRIPT_PATH="install/macos/02-brew-packages.sh"
  TEST_BIN_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_BIN_DIR"
}

write_brew_stub() {
  local installed_formulae="$1"
  local installed_casks="$2"

  cat >"$TEST_BIN_DIR/brew" <<EOF
#!/usr/bin/env bash
set -euo pipefail

if [ "\$1" = "list" ] && [ "\$2" = "--formula" ]; then
  cat <<'FORMULAE'
${installed_formulae}
FORMULAE
  exit 0
fi

if [ "\$1" = "list" ] && [ "\$2" = "--cask" ]; then
  cat <<'CASKS'
${installed_casks}
CASKS
  exit 0
fi

if [ "\$1" = "install" ]; then
  echo "INSTALL \$*"
  exit 0
fi

if [ "\$1" = "tap" ]; then
  echo "TAP \$2"
  exit 0
fi

echo "UNEXPECTED: \$*" >&2
exit 2
EOF

  chmod +x "$TEST_BIN_DIR/brew"
}

write_mas_stub() {
  local installed_apps="$1"
  local mode="${2:-success}"

  cat >"$TEST_BIN_DIR/mas" <<EOF
#!/usr/bin/env bash
set -euo pipefail

if [ "\$1" = "list" ]; then
  cat <<'MAS_APPS'
${installed_apps}
MAS_APPS
  exit 0
fi

if [ "\$1" = "get" ]; then
  if [ "${mode}" = "get_fail" ]; then
    echo "GET FAILED \$2" >&2
    exit 1
  fi
  echo "GET \$2"
  exit 0
fi

if [ "\$1" = "install" ]; then
  echo "INSTALL \$2"
  exit 0
fi

echo "UNEXPECTED: \$*" >&2
exit 2
EOF

  chmod +x "$TEST_BIN_DIR/mas"
}

@test "brew packages script exists" {
  [ -f "$SCRIPT_PATH" ]
}

@test "brew packages script is executable" {
  [ -x "$SCRIPT_PATH" ]
}

@test "brew packages script has proper error handling" {
  run grep "set -Eeuo pipefail" "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script does not reference external Brewfile" {
  run grep -E "brew bundle|Brewfile" "$SCRIPT_PATH"
  [ "$status" -ne 0 ]
}

@test "brew packages script defines taps array" {
  run grep -E '^[[:space:]]*(local[[:space:]]+(-a[[:space:]]+)?)?taps=\(' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines formulae array" {
  run grep -E '^[[:space:]]*(local[[:space:]]+(-a[[:space:]]+)?)?formulae=\(' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines casks array" {
  run grep -E '^[[:space:]]*(local[[:space:]]+(-a[[:space:]]+)?)?casks=\(' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines mas_apps array" {
  run grep -E '^[[:space:]]*(local[[:space:]]+(-a[[:space:]]+)?)?mas_apps=\(' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines install_formula_if_missing function" {
  run grep -E '^function install_formula_if_missing\(\)' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines install_cask_if_missing function" {
  run grep -E '^function install_cask_if_missing\(\)' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines load_installed_packages function" {
  run grep -E '^function load_installed_packages\(\)' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script defines install_mas_app_if_missing function" {
  run grep -E '^function install_mas_app_if_missing\(\)' "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
}

@test "brew packages script runs without errors in dry-run mode" {
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN]"* ]]
}

@test "brew packages dry-run output includes tap commands" {
  if ! command -v brew &>/dev/null; then
    skip "Requires Homebrew to be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Tapping Homebrew repositories"* ]]
  [[ "$output" == *"[DRY RUN] brew tap"* ]]
}

@test "brew packages dry-run output includes formulae commands" {
  if ! command -v brew &>/dev/null; then
    skip "Requires Homebrew to be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing Homebrew formulae"* ]]
  [[ "$output" == *"[DRY RUN] brew install"* ]]
}

@test "brew packages dry-run output includes cask commands" {
  if ! command -v brew &>/dev/null; then
    skip "Requires Homebrew to be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing Homebrew casks"* ]]
  [[ "$output" == *"[DRY RUN] brew install --cask"* ]]
}

@test "brew packages dry-run output includes mas commands" {
  if ! command -v brew &>/dev/null; then
    skip "Requires Homebrew to be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing Mac App Store apps"* ]]
  [[ "$output" == *"[DRY RUN] mas get 1429033973"* ]]
}

@test "brew packages skips installed formula and installs missing formula" {
  write_brew_stub $'bash\nmise\npython@3.12' $'1password\ngoogle-chrome'
  write_mas_stub ""

  run env PATH="$TEST_BIN_DIR:$PATH" bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[SKIP] bash is already installed"* ]]
  [[ "$output" == *"INSTALL install tree"* ]]
}

@test "brew packages skips installed cask and installs missing cask" {
  write_brew_stub $'bash\nmise\npython@3.12\ntree' $'1password\ngoogle-chrome'
  write_mas_stub ""

  run env PATH="$TEST_BIN_DIR:$PATH" bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[SKIP] 1password is already installed"* ]]
  [[ "$output" == *"INSTALL install --cask claude"* ]]
}

@test "brew packages installs mas formula when mas is missing from installed formulae" {
  write_brew_stub $'bash\nmise\npython@3.12\ntree' $'1password\ngoogle-chrome'
  write_mas_stub ""

  run env PATH="$TEST_BIN_DIR:$PATH" bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"INSTALL install mas"* ]]
}

@test "brew packages skips installed mas app and installs missing mas app" {
  write_brew_stub $'bash\nmise\npython@3.12\ntree\nmas' $'1password\ngoogle-chrome'
  write_mas_stub $'1429033973 RunCat (3.9)'

  run env PATH="$TEST_BIN_DIR:$PATH" bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[SKIP] mas app 1429033973 is already installed"* ]]
}

@test "brew packages falls back to mas install when mas get fails" {
  write_brew_stub $'bash\nmise\npython@3.12\ntree\nmas' $'1password\ngoogle-chrome'
  write_mas_stub "" "get_fail"

  run env PATH="$TEST_BIN_DIR:$PATH" bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[INFO] mas get failed for 1429033973; falling back to mas install"* ]]
  [[ "$output" == *"INSTALL 1429033973"* ]]
}

@test "brew packages refreshes installed lists before mas app installation" {
  formula_count_file="$TEST_BIN_DIR/formula_count"
  cask_count_file="$TEST_BIN_DIR/cask_count"
  : >"$formula_count_file"
  : >"$cask_count_file"

  cat >"$TEST_BIN_DIR/brew" <<EOF
#!/usr/bin/env bash
set -euo pipefail

if [ "\$1" = "list" ] && [ "\$2" = "--formula" ]; then
  echo x >>"$formula_count_file"
  cat <<'FORMULAE'
bash
mise
python@3.12
FORMULAE
  exit 0
fi

if [ "\$1" = "list" ] && [ "\$2" = "--cask" ]; then
  echo x >>"$cask_count_file"
  cat <<'CASKS'
1password
google-chrome
CASKS
  exit 0
fi

if [ "\$1" = "install" ]; then
  exit 0
fi

if [ "\$1" = "tap" ]; then
  exit 0
fi
EOF
  chmod +x "$TEST_BIN_DIR/brew"
  write_mas_stub ""

  run env PATH="$TEST_BIN_DIR:$PATH" bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]

  run wc -l <"$formula_count_file"
  [ "$status" -eq 0 ]
  [ "$output" -eq 2 ]

  run wc -l <"$cask_count_file"
  [ "$status" -eq 0 ]
  [ "$output" -eq 2 ]
}

@test "brew packages dry-run skips gracefully without Homebrew" {
  if command -v brew &>/dev/null; then
    skip "This test requires Homebrew to NOT be installed"
  fi
  run env DRY_RUN=true bash "$SCRIPT_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY RUN] Homebrew is not installed"* ]]
}
