#!/usr/bin/env bash
set -Eeuo pipefail

# kcovのインストール確認（必要に応じて）
if ! command -v kcov &>/dev/null; then
    echo "Installing kcov..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Ubuntu/Debian - kcovはUbuntu 24.04のデフォルトリポジトリにない
        echo "Note: kcov is not available in Ubuntu 24.04 default repositories"
        echo "Skipping kcov installation and running tests without coverage"
        echo "Coverage measurement is only available on macOS for now"
        bats tests/install/
        bats tests/files/
        exit 0
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install kcov || {
            echo "Warning: Failed to install kcov via brew"
            echo "Falling back to running tests without coverage"
            bats tests/install/
            bats tests/files/
            exit 0
        }
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

# kcovが利用可能かどうか再確認
if command -v kcov &>/dev/null; then
    echo "Running tests with coverage measurement..."
    # カバレッジディレクトリの作成
    mkdir -p coverage
    
    # カバレッジ付きでテスト実行
    kcov --clean --include-path=install/ \
        coverage/ \
        bats tests/install/
    
    # tests/files/ もテスト
    bats tests/files/
else
    echo "kcov not available, running tests without coverage..."
    bats tests/install/
    bats tests/files/
fi
