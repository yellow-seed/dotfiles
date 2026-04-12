#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/yellow-seed/dotfiles.git}"

function bootstrap_clone() {
  if ! command -v git &>/dev/null; then
    echo "Error: git is not installed. Please install git and try again." >&2
    exit 1
  fi

  local temp_dir
  temp_dir="$(mktemp -d)"
  echo "Required scripts not found locally. Cloning dotfiles repository..."
  git clone "${DOTFILES_REPO}" "${temp_dir}/dotfiles"
  bash "${temp_dir}/dotfiles/setup.sh"
  local exit_code=$?
  rm -rf "${temp_dir}"
  exit ${exit_code}
}

function run_script() {
  local script_path="$1"

  if [ ! -f "${script_path}" ]; then
    echo "Error: ${script_path} not found" >&2
    exit 1
  fi

  bash "${script_path}"
}

function main() {
  if [ ! -d "${SCRIPT_DIR}/install" ]; then
    bootstrap_clone
  fi

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

if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  main
fi
