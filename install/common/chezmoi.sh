#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモード
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

DRY_RUN="${DRY_RUN:-false}"
declare -r GITHUB_USERNAME="${GITHUB_USERNAME:-yellow-seed}"

function run_chezmoi() {
  if command -v curl &>/dev/null; then
    echo "Using curl to download chezmoi installer..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "${GITHUB_USERNAME}"
  elif command -v wget &>/dev/null; then
    echo "Using wget to download chezmoi installer..."
    sh -c "$(wget -qO- get.chezmoi.io)" -- init --apply "${GITHUB_USERNAME}"
  else
    echo "Error: Neither curl nor wget is available. Please install curl or wget to proceed." >&2
    echo "On Debian/Ubuntu: sudo apt-get install curl"
    echo "On macOS: brew install curl"
    exit 1
  fi
}

function main() {
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would run chezmoi setup for ${GITHUB_USERNAME}"
    return 0
  fi

  run_chezmoi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
