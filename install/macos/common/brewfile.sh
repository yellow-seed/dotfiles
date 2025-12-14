#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Brewfile関連の関数群
function is_brew_exists() {
    command -v brew &>/dev/null
}

function install_brewfile() {
    if ! is_brew_exists; then
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
