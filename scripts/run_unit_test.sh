#!/usr/bin/env bash
set -Eeuo pipefail

# kcoのインストール確認（必要に応じて）
if ! command -v kcov &>/dev/null; then
    echo "Installing kcov..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Ubuntu/Debian
        sudo apt-get update
        sudo apt-get install -y kcov
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install kcov
    else
        echo "Warning: kcov installation not supported on this OS"
        echo "Falling back to running tests without coverage"
        if ! command -v bats &>/dev/null; then
            echo "Error: bats is not installed"
            exit 1
        fi
        bats tests/install/
        bats tests/files/
        exit 0
    fi
fi

# カバレッジディレクトリの作成
mkdir -p coverage

# カバレッジ付きでテスト実行
kcov --clean --include-path=install/ \
    coverage/ \
    bats tests/install/

# tests/files/ もテスト
bats tests/files/
