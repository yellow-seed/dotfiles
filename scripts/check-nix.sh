#!/usr/bin/env bash
# Run the same Nix lint checks as CI (nixfmt, statix, deadnix).
# Requires Nix with flakes enabled.
set -Eeuo pipefail

NIX_FILES="install/macos/nix/flake.nix install/macos/nix/darwin/default.nix"
NIX_DIR="install/macos/nix"
NIX_CMD="nix --extra-experimental-features 'nix-command flakes'"

if ! command -v nix &>/dev/null; then
	echo "error: nix not found. Install via https://install.determinate.systems/nix" >&2
	exit 1
fi

echo "==> nixfmt-rfc-style --check"
# shellcheck disable=SC2086
eval $NIX_CMD run nixpkgs#nixfmt-rfc-style -- --check $NIX_FILES

echo "==> statix check"
# shellcheck disable=SC2086
eval $NIX_CMD run nixpkgs#statix -- check --config "$NIX_DIR/statix.toml" $NIX_DIR

echo "==> deadnix --fail"
# shellcheck disable=SC2086
eval $NIX_CMD run nixpkgs#deadnix -- --fail $NIX_FILES

echo "All Nix checks passed."
