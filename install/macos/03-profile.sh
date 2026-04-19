#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# ドライランモード設定
DRY_RUN="${DRY_RUN:-false}"
DOTFILES_PROFILE="${DOTFILES_PROFILE:-}"

function usage() {
  cat <<'EOF'
Usage: install/macos/03-profile.sh [--profile <name>]

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

# プロファイルの検出（共通をデフォルト、ホスト名による自動判定、環境変数で上書き）
function detect_profile() {
  local profile="common"
  local hostname_lower
  hostname_lower="$(hostname | tr '[:upper:]' '[:lower:]')"

  if [ -z "${hostname_lower}" ]; then
    echo "Warning: hostname could not be detected; using profile=common (only common packages will be installed)" >&2
  else
    local work_hostnames=("work-laptop" "work-desktop" "corp-mac")
    local work_host
    for work_host in "${work_hostnames[@]}"; do
      if [ "${hostname_lower}" = "${work_host}" ]; then
        profile="work"
        break
      fi
    done
  fi

  if [ -n "${DOTFILES_PROFILE}" ]; then
    profile="${DOTFILES_PROFILE}"
  fi

  echo "${profile}"
}

function install_profile_packages() {
  local profile
  profile="$(detect_profile)"

  if [ "${profile}" = "common" ]; then
    echo "Profile is common; skipping profile-specific packages"
    return 0
  fi

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local profile_script="${script_dir}/${profile}/brew-packages.sh"

  if [ -f "${profile_script}" ]; then
    echo "Installing ${profile}-specific packages..."
    bash "${profile_script}"
  else
    echo "Warning: ${profile} brew-packages.sh not found at ${profile_script}, skipping profile-specific packages"
  fi
}

function main() {
  parse_args "$@"
  install_profile_packages
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
