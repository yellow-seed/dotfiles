#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

DRY_RUN="${DRY_RUN:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_DIR="${SCRIPT_DIR}/nix"
NIX_DAEMON_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

function is_ci() {
  [ -n "${CI:-}" ]
}

function is_tty() {
  [ -t 0 ]
}

function is_skip_mode() {
  [ "${DRY_RUN}" = "true" ] || is_ci || ! is_tty
}

function skip_log() {
  local prefix="[SKIP]"

  if [ "${DRY_RUN}" = "true" ]; then
    prefix="[DRY RUN]"
  fi

  echo "${prefix} $*"
}

function is_nix_installed() {
  command -v nix &>/dev/null
}

function is_darwin_rebuild_installed() {
  command -v darwin-rebuild &>/dev/null
}

function get_flake_target() {
  if [[ "$(uname -m)" == "arm64" ]]; then
    echo ".#dotfiles"
  else
    echo ".#dotfiles-intel"
  fi
}

function validate_nix_dir() {
  if [ ! -d "${NIX_DIR}" ]; then
    echo "Error: expected Nix configuration directory at '${NIX_DIR}', but it does not exist." >&2
    exit 1
  fi

  if [ ! -f "${NIX_DIR}/flake.nix" ]; then
    echo "Error: expected 'flake.nix' in '${NIX_DIR}', but it was not found." >&2
    echo "Ensure the Nix flake is present and correctly configured before running this script." >&2
    exit 1
  fi
}

function load_nix_daemon_profile() {
  if [ -f "${NIX_DAEMON_PROFILE}" ]; then
    # shellcheck source=/dev/null
    . "${NIX_DAEMON_PROFILE}"
  fi
}

function install_nix() {
  if is_nix_installed; then
    echo "Nix is already installed."
    return 0
  fi

  if is_skip_mode; then
    skip_log "Would install Nix via Determinate Systems installer."
    skip_log "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
    return 0
  fi

  echo "Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  load_nix_daemon_profile
}

function check_flake() {
  if is_skip_mode; then
    skip_log "Would run: nix flake check (in ${NIX_DIR})"
    return 0
  fi

  if ! is_nix_installed; then
    echo "Error: nix is not installed. Re-run this script or install Nix manually:" >&2
    echo "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install" >&2
    exit 1
  fi

  echo "Checking nix flake..."
  (cd "${NIX_DIR}" && nix flake check)
}

function apply_nix_darwin() {
  local target
  target="$(get_flake_target)"

  if is_skip_mode; then
    if is_darwin_rebuild_installed; then
      skip_log "Would run: sudo darwin-rebuild switch --flake ${target} (in ${NIX_DIR})"
    else
      skip_log "Would run: sudo nix run nix-darwin#darwin-rebuild -- switch --flake ${target} (in ${NIX_DIR})"
    fi
    return 0
  fi

  if is_darwin_rebuild_installed; then
    echo "Applying nix-darwin configuration (${target})..."
    (cd "${NIX_DIR}" && sudo darwin-rebuild switch --flake "${target}")
  else
    echo "darwin-rebuild not found; running first-time nix-darwin activation..."
    (cd "${NIX_DIR}" && sudo nix run nix-darwin#darwin-rebuild -- switch --flake "${target}")
  fi
}

function main() {
  validate_nix_dir
  install_nix
  check_flake
  apply_nix_darwin
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
