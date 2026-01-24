#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

DRY_RUN="${DRY_RUN:-false}"

function setup_homebrew_path() {
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would configure Homebrew PATH"
    return 0
  fi

  if [[ $(arch) == "arm64" ]]; then
    echo "Detected Apple Silicon, setting up Homebrew path..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ $(arch) == "x86_64" ]]; then
    echo "Detected Intel Mac, setting up Homebrew path..."
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

function main() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  echo "Step 1: Installing Homebrew..."
  bash "${script_dir}/01-brew.sh"

  setup_homebrew_path

  echo "Step 2: Installing common packages..."
  bash "${script_dir}/02-brewfile.sh"

  echo "Step 3: Installing profile-specific packages..."
  bash "${script_dir}/03-profile.sh"

  echo "macOS setup completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
