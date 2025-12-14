#!/usr/bin/env bash
# dotfilesのセットアップスクリプト
# chezmoiを使用してdotfilesをインストール・適用します

# エラーハンドリング設定
# -E: ERRトラップを関数やサブシェルに継承
# -e: コマンドが0以外の終了コードを返したら即座に終了
# -u: 未定義の変数を参照したらエラーにする
# -o pipefail: パイプライン内のコマンドが1つでも失敗したら全体を失敗とする
set -Eeuo pipefail

# デバッグモード
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 環境変数の設定（環境変数が未設定の場合はデフォルト値を使用）
declare -r GITHUB_USERNAME="${GITHUB_USERNAME:-yellow-seed}"
declare -r DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/${GITHUB_USERNAME}/dotfiles.git}"
declare -r BRANCH_NAME="${BRANCH_NAME:-main}"

# OS検出
function get_os_type() {
    uname
}

# OS環境の初期化（Phase 2で実装）
function initialize_os_env() {
    local ostype
    ostype="$(get_os_type)"
    
    case "${ostype}" in
        Darwin)
            # macOS処理（Phase 2で実装）
            :
            ;;
        Linux)
            # Linux処理（Phase 2で実装）
            :
            ;;
        *)
            echo "Unsupported OS: ${ostype}" >&2
            exit 1
            ;;
    esac
}

# chezmoi のセットアップ
function run_chezmoi() {
    # chezmoiのインストールとセットアップを実行
    # curl または wget でインストールスクリプトを取得
    # 1. インストールスクリプトを取得:
    #    curl の場合:
    #      -f: HTTPエラー時に失敗
    #      -s: サイレントモード（進捗表示なし）
    #      -L: リダイレクトをフォロー
    #      -S: エラー時はメッセージを表示
    #    wget の場合:
    #      -q: 静かモード（進捗表示なし）
    #      -O-: 標準出力に出力
    # 2. 取得したスクリプトを sh で実行
    # 3. -- 以降は chezmoi のインストールスクリプトへの引数
    #    init: リポジトリを初期化
    #    --apply: 設定ファイルを即座にホームディレクトリに適用
    #    ${GITHUB_USERNAME}: GitHubのユーザー名を指定してリポジトリを特定
    if command -v curl &> /dev/null; then
        echo "Using curl to download chezmoi installer..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "${GITHUB_USERNAME}"
    elif command -v wget &> /dev/null; then
        echo "Using wget to download chezmoi installer..."
        sh -c "$(wget -qO- get.chezmoi.io)" -- init --apply "${GITHUB_USERNAME}"
    else
        echo "Error: Neither curl nor wget is available. Please install curl or wget to proceed."
        echo "On Debian/Ubuntu: sudo apt-get install curl"
        echo "On macOS: brew install curl"
        exit 1
    fi
}

# dotfiles の初期化
function initialize_dotfiles() {
    initialize_os_env
    run_chezmoi
}

# メイン処理
function main() {
    echo "Setting up dotfiles from ${DOTFILES_REPO}"
    initialize_dotfiles
}

# スクリプトが直接実行された場合のみmainを実行（テスト時はスキップ）
# BASH_SOURCE[0]が未定義の場合（curl/wgetでの実行時）も実行する
if [ -z "${BASH_SOURCE[0]:-}" ] || [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main
fi
