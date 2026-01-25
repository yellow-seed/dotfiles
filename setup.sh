#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function run_script() {
  local script_path="$1"

  if [ ! -f "${script_path}" ]; then
    echo "Error: ${script_path} not found" >&2
    exit 1
  fi

  bash "${script_path}"
}

function main() {
  local os_type
  os_type="$(uname)"

  case "${os_type}" in
  Darwin)
    echo "Detected macOS environment"
    run_script "${SCRIPT_DIR}/install/macos/setup.sh"
    ;;
  Linux)
    echo "Detected Linux environment"
    run_script "${SCRIPT_DIR}/install/ubuntu/setup.sh"
    ;;
  *)
    echo "Error: Unsupported OS: ${os_type}" >&2
    exit 1
    ;;
  esac

  echo "Running chezmoi setup..."
  run_script "${SCRIPT_DIR}/install/common/chezmoi.sh"

  echo "Dotfiles setup completed successfully!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
