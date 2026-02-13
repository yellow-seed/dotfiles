#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# ドライランモード設定
DRY_RUN="${DRY_RUN:-false}"

# Homebrew関連の関数群
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

function install_packages() {
  if ! is_brew_exists; then
    if [ "${DRY_RUN}" = "true" ]; then
      echo "[DRY RUN] Homebrew is not installed; skipping package installation."
      return 0
    fi
    echo "Error: Homebrew is not installed"
    exit 1
  fi

  local taps=(
    "aws/tap"
    "dotenvx/brew"
    "go-swagger/go-swagger"
  )

  local formulae=(
    "bash"
    "mise"
    "python@3.12"
    "tree"
  )

  local casks=(
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

  echo "Tapping Homebrew repositories..."
  for tap in "${taps[@]}"; do
    run_brew tap "$tap"
  done

  echo "Installing Homebrew formulae..."
  for formula in "${formulae[@]}"; do
    run_brew install "$formula"
  done

  echo "Installing Homebrew casks..."
  for cask in "${casks[@]}"; do
    run_brew install --cask "$cask"
  done
}

# メイン処理
function main() {
  install_packages
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
