#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# ドライランモード設定（子スクリプトにも伝搬）
export DRY_RUN="${DRY_RUN:-false}"

function main() {
  echo "Initializing Linux environment..."
  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Linux setup is not yet implemented."
    return 0
  fi

  echo "Linux setup is not yet implemented."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
