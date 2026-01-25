#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# ドライランモード設定（子スクリプトにも伝搬）
export DRY_RUN="${DRY_RUN:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

  run_step "Step 1: Installing Homebrew..." "${SCRIPT_DIR}/01-brew.sh"
  configure_homebrew_path
  run_step "Step 2: Installing common packages..." "${SCRIPT_DIR}/02-brewfile.sh"
  run_step "Step 3: Installing profile-specific packages..." "${SCRIPT_DIR}/03-profile.sh"

  echo "macOS setup completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
