#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# ドライランモード設定
DRY_RUN="${DRY_RUN:-false}"

# パッケージ定義
TAPS=(
  "aws/tap"
  "dotenvx/brew"
  "go-swagger/go-swagger"
  "homebrew/bundle"
)

FORMULAE=(
  "bash"
  "mise"
  "python@3.12"
  "tree"
)

CASKS=(
  "1password"
  "adobe-acrobat-reader"
  "claude"
  "claude-code"
  "cursor"
  "dbeaver-community"
  "docker-desktop"
  "ghostty"
  "github"
  "google-chrome"
  "postman"
  "raycast"
  "shottr"
  "visual-studio-code"
  "warp"
)

function is_brew_exists() {
  command -v brew &>/dev/null
}

function run_brew() {
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] brew $*"
    return 0
  fi

  brew "$@"
}

function ensure_brew() {
  if is_brew_exists; then
    return 0
  fi

  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Homebrew is not installed; skipping package installation."
    return 1
  fi

  echo "Error: Homebrew is not installed"
  exit 1
}

function tap_exists() {
  local tap="$1"
  brew tap | grep -Fxq "$tap"
}

function formula_exists() {
  local formula="$1"
  brew list --formula "$formula" &>/dev/null
}

function cask_exists() {
  local cask="$1"
  brew list --cask "$cask" &>/dev/null
}

function install_taps() {
  for tap in "${TAPS[@]}"; do
    if tap_exists "$tap"; then
      echo "Tap already added: $tap"
      continue
    fi
    run_brew tap "$tap"
  done
}

function install_formulae() {
  for formula in "${FORMULAE[@]}"; do
    if formula_exists "$formula"; then
      echo "Formula already installed: $formula"
      continue
    fi
    run_brew install "$formula"
  done
}

function install_casks() {
  for cask in "${CASKS[@]}"; do
    if cask_exists "$cask"; then
      echo "Cask already installed: $cask"
      continue
    fi
    run_brew install --cask "$cask"
  done
}

function install_packages() {
  if ! ensure_brew; then
    return 0
  fi

  install_taps
  install_formulae
  install_casks
}

function main() {
  install_packages
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
