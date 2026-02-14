#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

declare -r GITHUB_USERNAME="${GITHUB_USERNAME:-yellow-seed}"
declare -r CHEZMOI_BIN_DIR="${CHEZMOI_BIN_DIR:-${HOME}/.local/bin}"
DRY_RUN="${DRY_RUN:-false}"

function setup_chezmoi_bin_dir() {
  mkdir -p "${CHEZMOI_BIN_DIR}"
  if [[ ":${PATH}:" != *":${CHEZMOI_BIN_DIR}:"* ]]; then
    export PATH="${CHEZMOI_BIN_DIR}:${PATH}"
  fi
}

function run_chezmoi() {
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would install chezmoi for ${GITHUB_USERNAME}"
    return 0
  fi

  setup_chezmoi_bin_dir

  if command -v curl &>/dev/null; then
    echo "Using curl to download chezmoi installer..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${CHEZMOI_BIN_DIR}" init --apply "${GITHUB_USERNAME}"
  elif command -v wget &>/dev/null; then
    echo "Using wget to download chezmoi installer..."
    sh -c "$(wget -qO- get.chezmoi.io)" -- -b "${CHEZMOI_BIN_DIR}" init --apply "${GITHUB_USERNAME}"
  else
    echo "Error: Neither curl nor wget is available. Please install curl or wget to proceed." >&2
    echo "On Debian/Ubuntu: sudo apt-get install curl" >&2
    echo "On macOS: brew install curl" >&2
    exit 1
  fi
}

function main() {
  run_chezmoi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
