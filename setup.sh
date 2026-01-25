#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモード
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# OS検出
OS_TYPE="$(uname)"

# OS別セットアップスクリプトの実行
case "${OS_TYPE}" in
Darwin)
  echo "Detected macOS environment"
  bash "${SCRIPT_DIR}/install/macos/setup.sh"
  ;;
Linux)
  echo "Detected Linux environment"
  bash "${SCRIPT_DIR}/install/ubuntu/setup.sh"
  ;;
*)
  echo "Error: Unsupported OS: ${OS_TYPE}" >&2
  exit 1
  ;;
esac

# chezmoi共通処理
echo "Running chezmoi setup..."
bash "${SCRIPT_DIR}/install/common/chezmoi.sh"

echo "Dotfiles setup completed successfully!"
