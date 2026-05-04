#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

DRY_RUN="${DRY_RUN:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_DIR="${SCRIPT_DIR}/nix"

function is_ci() {
  [ -n "${CI:-}" ]
}

function is_tty() {
  [ -t 0 ]
}

function is_skip_mode() {
  [ "${DRY_RUN}" = "true" ] || is_ci || ! is_tty
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

function install_nix() {
  if is_nix_installed; then
    echo "Nix is already installed."
    return 0
  fi

  if is_skip_mode; then
    echo "[DRY RUN] Would install Nix via Determinate Systems installer."
    echo "[DRY RUN]   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
    return 0
  fi

  echo "Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
}

function check_flake() {
  if is_skip_mode; then
    echo "[DRY RUN] Would run: nix flake check (in ${NIX_DIR})"
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
    echo "[DRY RUN] Would run: sudo darwin-rebuild switch --flake ${target} (in ${NIX_DIR})"
    return 0
  fi

  if is_darwin_rebuild_installed; then
    echo "Applying nix-darwin configuration (${target})..."
    (cd "${NIX_DIR}" && sudo darwin-rebuild switch --flake "${target}")
  else
    echo "darwin-rebuild not found; running first-time nix-darwin activation..."
    (cd "${NIX_DIR}" && nix run nix-darwin -- switch --flake "${target}")
  fi
}

function main() {
  install_nix
  check_flake
  apply_nix_darwin
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
