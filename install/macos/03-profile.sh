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
    echo "Warning: hostname could not be detected; using profile=common (only common packages will be installed)"
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

function install_profile_brewfile() {
  local profile
  profile="$(detect_profile)"
  echo "Using profile: ${profile}"

  if [ "${profile}" = "common" ]; then
    echo "Profile is common; skipping profile-specific Brewfile (common packages already installed)"
    return 0
  fi

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local profile_brewfile="${script_dir}/${profile}/Brewfile"

  if [ -f "${profile_brewfile}" ]; then
    if [ "${DRY_RUN}" = "true" ]; then
      echo "[DRY RUN] Would install ${profile}-specific packages from ${profile_brewfile}"
      return 0
    fi

    echo "Installing ${profile}-specific packages..."
    brew bundle --file="${profile_brewfile}"
  else
    echo "Warning: ${profile} Brewfile not found at ${profile_brewfile}, skipping profile-specific packages"
  fi
}

function main() {
  install_profile_brewfile
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
