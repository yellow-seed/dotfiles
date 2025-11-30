#!/usr/bin/env bash
# dotfilesのセットアップスクリプト
# chezmoiを使用してdotfilesをインストール・適用します

# エラーハンドリング設定
# -E: ERRトラップを関数やサブシェルに継承
# -e: コマンドが0以外の終了コードを返したら即座に終了
# -u: 未定義の変数を参照したらエラーにする
# -o pipefail: パイプライン内のコマンドが1つでも失敗したら全体を失敗とする
set -Eeuo pipefail

# 環境変数の設定（環境変数が未設定の場合はデフォルト値を使用）
GITHUB_USERNAME="${GITHUB_USERNAME:-yellow-seed}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/${GITHUB_USERNAME}/dotfiles.git}"

# セットアップ開始メッセージ
echo "Setting up dotfiles from ${DOTFILES_REPO}"

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
  echo "Error: curl or wget is required to install chezmoi"
  exit 1
fi
