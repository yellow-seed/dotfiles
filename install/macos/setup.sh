#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

DRY_RUN="${DRY_RUN:-false}"

function ensure_script() {
  local script_path="$1"

  if [ ! -f "${script_path}" ]; then
    echo "Error: script not found at ${script_path}" >&2
    exit 1
  fi

  if [ ! -x "${script_path}" ]; then
    echo "Error: script is not executable at ${script_path}" >&2
    exit 1
  fi
}

function setup_homebrew_path() {
  if [[ $(arch) == "arm64" ]]; then
    echo "Detected Apple Silicon, setting up Homebrew path..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ $(arch) == "x86_64" ]]; then
    echo "Detected Intel Mac, setting up Homebrew path..."
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

function run_step() {
  local step_label="$1"
  local step_script="$2"

  echo "${step_label}"

  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would run: ${step_script}"
    return 0
  fi

  bash "${step_script}"
}

function main() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  local brew_script="${script_dir}/01-brew.sh"
  local brewfile_script="${script_dir}/02-brewfile.sh"
  local profile_script="${script_dir}/03-profile.sh"

  ensure_script "${brew_script}"
  ensure_script "${brewfile_script}"
  ensure_script "${profile_script}"

  echo "Initializing macOS environment..."

  run_step "Step 1: Installing Homebrew..." "${brew_script}"

  if [ "${DRY_RUN}" != "true" ]; then
    setup_homebrew_path
  fi

  run_step "Step 2: Installing common packages..." "${brewfile_script}"
  run_step "Step 3: Installing profile-specific packages..." "${profile_script}"

  echo "macOS environment initialization completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
