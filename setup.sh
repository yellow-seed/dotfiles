#!/usr/bin/env bash
set -Eeuo pipefail

GITHUB_USERNAME="${GITHUB_USERNAME:-yellow-seed}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/${GITHUB_USERNAME}/dotfiles.git}"

echo "Setting up dotfiles from ${DOTFILES_REPO}"

# chezmoiのインストールとセットアップ
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "${GITHUB_USERNAME}"
