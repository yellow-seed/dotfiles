#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# chezmoi関連の関数群
function is_chezmoi_exists() {
    command -v chezmoi &>/dev/null
}

function install_chezmoi() {
    if ! is_chezmoi_exists; then
        echo "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)"
    else
        echo "chezmoi is already installed."
    fi
}

# メイン処理
function main() {
    install_chezmoi
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
