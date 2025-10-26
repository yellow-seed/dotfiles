#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# ツール固有の関数群
function is_tool_exists() {
    command -v tool_name &>/dev/null
}

function install_tool() {
    if ! is_tool_exists; then
        # プラットフォーム固有のインストール処理
        echo "Installing tool_name..."
    fi
}

# メイン処理
function main() {
    install_tool
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
