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
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1

  local brew_step="${script_dir}/01-brew.sh"
  local brewfile_step="${script_dir}/02-brewfile.sh"
  local profile_step="${script_dir}/03-profile.sh"

  local step
  for step in "${brew_step}" "${brewfile_step}" "${profile_step}"; do
    if [ ! -f "${step}" ]; then
      echo "Error: setup step not found at ${step}" >&2
      return 1
    fi
  done

  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would run macOS setup steps:"
    echo "  - ${brew_step}"
    echo "  - ${brewfile_step}"
    echo "  - ${profile_step}"
    return 0
  fi

  echo "Step 1: Installing Homebrew..."
  bash "${brew_step}"

  setup_homebrew_path

  echo "Step 2: Installing common packages..."
  bash "${brewfile_step}"

  echo "Step 3: Installing profile-specific packages..."
  bash "${profile_step}"

  echo "macOS setup completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
