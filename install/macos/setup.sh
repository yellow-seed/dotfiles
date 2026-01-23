#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

DRY_RUN="${DRY_RUN:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function run_step() {
  local step_label="$1"
  local step_script="$2"

  echo "${step_label}"

  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would run ${step_script}"
    return 0
  fi

  if [ ! -f "${step_script}" ]; then
    echo "Error: ${step_script} not found" >&2
    exit 1
  fi

  bash "${step_script}"
}

function setup_brew_path() {
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would configure Homebrew PATH"
    return 0
  fi

  if [[ $(arch) == "arm64" ]] && [ -x "/opt/homebrew/bin/brew" ]; then
    echo "Detected Apple Silicon, setting up Homebrew path..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi

  if [[ $(arch) == "x86_64" ]] && [ -x "/usr/local/bin/brew" ]; then
    echo "Detected Intel Mac, setting up Homebrew path..."
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi

  if command -v brew &>/dev/null; then
    echo "Setting up Homebrew path..."
    eval "$(brew shellenv)"
    return 0
  fi

  echo "Warning: Homebrew not found; skipping PATH setup" >&2
}

function main() {
  run_step "Step 1: Installing Homebrew..." "${SCRIPT_DIR}/01-brew.sh"
  setup_brew_path
  run_step "Step 2: Installing common packages..." "${SCRIPT_DIR}/02-brewfile.sh"
  run_step "Step 3: Installing profile-specific packages..." "${SCRIPT_DIR}/03-profile.sh"

  echo "macOS setup completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
