#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# ドライランモード設定
DRY_RUN="${DRY_RUN:-false}"

# Brewfile関連の関数群
function is_brew_exists() {
  command -v brew &>/dev/null
}

function install_brewfile() {
  if ! is_brew_exists; then
    if [ "${DRY_RUN}" = "true" ]; then
      echo "[DRY RUN] Homebrew is not installed; skipping brew bundle."
      return 0
    fi
    echo "Error: Homebrew is not installed"
    exit 1
  fi

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local brewfile="${script_dir}/Brewfile"

  if [ ! -f "$brewfile" ]; then
    echo "Error: Brewfile not found at ${brewfile}"
    exit 1
  fi

  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would install packages from Brewfile: ${brewfile}"
    return 0
  fi

  echo "Installing packages from Brewfile..."
  brew bundle --file="$brewfile"
}

# メイン処理
function main() {
  install_brewfile
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
