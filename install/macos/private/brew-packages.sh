#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../02-brew-packages.sh
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/../02-brew-packages.sh"

function run_go() {
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] go $*"
    return 0
  fi

  go "$@"
}

function install_go_package_if_missing() {
  local package="$1"
  local binary="$2"

  if command -v "${binary}" &>/dev/null; then
    echo "  [SKIP] ${binary} is already installed"
    return 0
  fi

  if [ "${DRY_RUN}" = "true" ]; then
    run_go install "${package}@latest"
    return 0
  fi

  if ! command -v go &>/dev/null; then
    echo "Error: go is not installed; cannot install ${package}" >&2
    exit 1
  fi

  run_go install "${package}@latest"
}

function install_packages() {
  local taps=()

  local formulae=(
    "qpdf"
  )

  local casks=(
    "1password-cli"
    "applite"
    "brave-browser"
    "chatgpt"
    "codex"
    "discord"
    "firefox"
    "gcloud-cli"
    "gitify"
    "lulu"
    "notion-calendar"
    "obsidian"
    "slack"
    "termius"
    "thebrowsercompany-dia"
  )

  local mas_apps=(
    "1569813296" # 1Password for Safari
    "302584613"  # Kindle
    "539883307"  # LINE
  )

  if ! is_brew_exists; then
    if [ "${DRY_RUN}" = "true" ]; then
      echo "[DRY RUN] Homebrew is not installed; skipping package installation."
      return 0
    fi
    echo "Error: Homebrew is not installed" >&2
    exit 1
  fi

  echo "Tapping private Homebrew repositories..."
  for tap in "${taps[@]}"; do
    run_brew tap "${tap}"
  done

  load_installed_packages

  echo "Installing private Homebrew formulae..."
  for formula in "${formulae[@]}"; do
    install_formula_if_missing "${formula}"
  done

  echo "Installing private Homebrew casks..."
  for cask in "${casks[@]}"; do
    install_cask_if_missing "${cask}"
  done

  load_installed_packages

  if [ "${DRY_RUN}" != "true" ] && ! is_mas_exists; then
    echo "Error: mas is not installed" >&2
    exit 1
  fi

  echo "Installing private Mac App Store apps..."
  for app_id in "${mas_apps[@]}"; do
    install_mas_app_if_missing "${app_id}"
  done
}

function main() {
  install_packages
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
