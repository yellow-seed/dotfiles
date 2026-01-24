#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

export DRY_RUN="${DRY_RUN:-false}"

# Homebrew関連の関数群
function is_brew_exists() {
  if command -v brew &>/dev/null; then
    return 0
  fi

  if [ -x "/opt/homebrew/bin/brew" ] || [ -x "/usr/local/bin/brew" ]; then
    return 0
  fi

  return 1
}

function install_brew() {
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would install Homebrew"
    return 0
  fi

  if ! is_brew_exists; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi
}

# メイン処理
function main() {
  install_brew
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
