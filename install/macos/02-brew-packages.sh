#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# ドライランモード設定
DRY_RUN="${DRY_RUN:-false}"
INSTALLED_FORMULAE=""
INSTALLED_CASKS=""
INSTALLED_MAS_APPS=""

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

function is_mas_exists() {
  command -v mas &>/dev/null
}

function run_mas() {
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] mas $*"
    return 0
  fi

  mas "$@"
}

function load_installed_packages() {
  INSTALLED_FORMULAE="$(brew list --formula)"
  INSTALLED_CASKS="$(brew list --cask)"

  if is_mas_exists; then
    INSTALLED_MAS_APPS="$(mas list | awk '{print $1}')"
  else
    INSTALLED_MAS_APPS=""
  fi
}

function is_formula_installed() {
  local formula="$1"
  grep -Fxq "$formula" <<<"${INSTALLED_FORMULAE}"
}

function is_cask_installed() {
  local cask="$1"
  grep -Fxq "$cask" <<<"${INSTALLED_CASKS}"
}

function install_formula_if_missing() {
  local formula="$1"
  if is_formula_installed "$formula"; then
    echo "  [SKIP] ${formula} is already installed"
    return 0
  fi

  run_brew install "$formula"
}

function install_cask_if_missing() {
  local cask="$1"
  if is_cask_installed "$cask"; then
    echo "  [SKIP] ${cask} is already installed"
    return 0
  fi

  run_brew install --cask "$cask"
}

function is_mas_app_installed() {
  local app_id="$1"
  grep -Fxq "$app_id" <<<"${INSTALLED_MAS_APPS}"
}

function install_mas_app_if_missing() {
  local app_id="$1"

  if is_mas_app_installed "$app_id"; then
    echo "  [SKIP] mas app ${app_id} is already installed"
    return 0
  fi

  if ! run_mas get "$app_id"; then
    echo "  [INFO] mas get failed for ${app_id}; falling back to mas install"
    run_mas install "$app_id"
  fi
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
  )

  local formulae=(
    "bash"
    "mas"
    "mise"
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
    "ente-auth"
  )

  local mas_apps=(
    "1429033973" # RunCat
  )

  echo "Tapping Homebrew repositories..."
  for tap in "${taps[@]}"; do
    run_brew tap "$tap"
  done

  load_installed_packages

  echo "Installing Homebrew formulae..."
  for formula in "${formulae[@]}"; do
    install_formula_if_missing "$formula"
  done

  echo "Installing Homebrew casks..."
  for cask in "${casks[@]}"; do
    install_cask_if_missing "$cask"
  done

  load_installed_packages

  if [ "${DRY_RUN}" != "true" ] && ! is_mas_exists; then
    echo "Error: mas is not installed"
    exit 1
  fi

  echo "Installing Mac App Store apps..."
  for app_id in "${mas_apps[@]}"; do
    install_mas_app_if_missing "$app_id"
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
