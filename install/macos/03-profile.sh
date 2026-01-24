#!/usr/bin/env bash
set -Eeuo pipefail

# デバッグモードの設定
if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

DRY_RUN="${DRY_RUN:-false}"

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

  if [ -n "${DOTFILES_PROFILE:-}" ]; then
    profile="${DOTFILES_PROFILE}"
  fi

  echo "${profile}"
}

function profile_brewfile_path() {
  local profile="$1"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  echo "${script_dir}/${profile}/Brewfile"
}

function install_profile_brewfile() {
  local profile
  profile="$(detect_profile)"
  echo "Using profile: ${profile}"

  if [ "${profile}" = "common" ]; then
    echo "Profile is common; skipping profile-specific Brewfile (common packages already installed)"
    return 0
  fi

  local profile_brewfile
  profile_brewfile="$(profile_brewfile_path "${profile}")"

  if [ ! -f "${profile_brewfile}" ]; then
    echo "Warning: ${profile} Brewfile not found at ${profile_brewfile}, skipping profile-specific packages"
    return 0
  fi

  if [ "${DRY_RUN}" = "true" ]; then
    echo "[DRY RUN] Would install ${profile}-specific packages from ${profile_brewfile}"
    return 0
  fi

  if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew is not installed" >&2
    exit 1
  fi

  echo "Installing ${profile}-specific packages..."
  brew bundle --file="${profile_brewfile}"
}

function main() {
  install_profile_brewfile
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
