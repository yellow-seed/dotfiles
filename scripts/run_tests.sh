#!/usr/bin/env bash
set -Eeuo pipefail

# Batsのインストール確認
if ! command -v bats &>/dev/null; then
    echo "Error: bats is not installed"
    exit 1
fi

# テスト実行
bats tests/install/
