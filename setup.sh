#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/yellow-seed/dotfiles.git}"
DOTFILES_CLONE_DIR="${DOTFILES_CLONE_DIR:-${HOME}/.local/share/chezmoi}"
DOTFILES_PROFILE="${DOTFILES_PROFILE:-}"

function usage() {
  cat <<'EOF'
Usage: setup.sh [--profile <name>]

Options:
  --profile <name>  Specify dotfiles profile (e.g. work, common)
EOF
}

function parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --profile)
      if [[ $# -lt 2 ]] || [[ -z "${2:-}" ]]; then
        echo "Error: --profile requires a non-empty value" >&2
        usage >&2
        exit 1
      fi
      DOTFILES_PROFILE="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    esac
  done
}

function bootstrap_clone() {
  local -a forwarded_args=("$@")

  if ! command -v git &>/dev/null; then
    echo "Error: git is not installed. Please install git and try again." >&2
    exit 1
  fi

  if [ ! -f "${DOTFILES_CLONE_DIR}/setup.sh" ] || [ ! -d "${DOTFILES_CLONE_DIR}/install" ]; then
    if [ -e "${DOTFILES_CLONE_DIR}" ]; then
      echo "Error: ${DOTFILES_CLONE_DIR} exists but is not a valid dotfiles checkout." >&2
      echo "Set DOTFILES_CLONE_DIR to an empty path, or remove the directory and retry." >&2
      exit 1
    fi
    echo "Required scripts not found locally. Cloning dotfiles repository..."
    mkdir -p "$(dirname "${DOTFILES_CLONE_DIR}")"
    git clone "${DOTFILES_REPO}" "${DOTFILES_CLONE_DIR}"
  fi

  bash "${DOTFILES_CLONE_DIR}/setup.sh" "${forwarded_args[@]}"
  exit $?
}

function run_script() {
  local script_path="$1"
  shift

  if [ ! -f "${script_path}" ]; then
    echo "Error: ${script_path} not found" >&2
    exit 1
  fi

  bash "${script_path}" "$@"
}

function main() {
  parse_args "$@"
  if [[ -n "${DOTFILES_PROFILE}" ]]; then
    export DOTFILES_PROFILE
  fi

  if [ ! -d "${SCRIPT_DIR}/install" ]; then
    bootstrap_clone "$@"
  fi

  local os_type
  os_type="$(uname)"

  case "${os_type}" in
  Darwin)
    echo "Detected macOS environment"
    run_script "${SCRIPT_DIR}/install/macos/setup.sh" "$@"
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
  main "$@"
fi
