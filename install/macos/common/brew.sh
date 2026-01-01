#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# Homebrew関連の関数群
function is_brew_exists() {
  command -v brew &>/dev/null
}

function install_brew() {
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
