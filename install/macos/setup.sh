#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# ドライランモード設定（子スクリプトにも伝搬）
export DRY_RUN="${DRY_RUN:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function is_ci() {
  [ -n "${CI:-}" ]
}

function is_tty() {
  [ -t 0 ]
}

function is_not_tty() {
  ! is_tty
}

function is_ci_or_not_tty() {
  is_ci || is_not_tty
}

function keepalive_sudo_macos() {
  sudo -v

  local parent_pid=$$
  (while true; do
    sudo -n true
    sleep 60
    kill -0 "$parent_pid" || exit
  done) &
}

function keepalive_sudo() {
  if is_ci_or_not_tty; then
    echo "Skipping sudo keepalive in CI or non-TTY environment"
    return 0
  fi

  keepalive_sudo_macos
}

function configure_homebrew_path() {
  if [[ $(arch) == "arm64" ]]; then
    if [ -x "/opt/homebrew/bin/brew" ]; then
      echo "Detected Apple Silicon, setting up Homebrew path..."
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  elif [[ $(arch) == "x86_64" ]]; then
    if [ -x "/usr/local/bin/brew" ]; then
      echo "Detected Intel Mac, setting up Homebrew path..."
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
}

function run_step() {
  local step_name="$1"
  local step_script="$2"

  echo "${step_name}"

  if [ ! -f "${step_script}" ]; then
    echo "Error: ${step_script} not found" >&2
    exit 1
  fi

  bash "${step_script}"
}

function main() {
  echo "Initializing macOS environment..."

  keepalive_sudo
  run_step "Step 1: Installing Homebrew..." "${SCRIPT_DIR}/01-brew.sh"
  configure_homebrew_path
  run_step "Step 2: Installing common packages..." "${SCRIPT_DIR}/02-brewfile.sh"
  run_step "Step 3: Installing profile-specific packages..." "${SCRIPT_DIR}/03-profile.sh"

  echo "macOS setup completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
