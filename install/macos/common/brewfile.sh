#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function is_brew_exists() {
    command -v brew &>/dev/null
}

function install_brewfile() {
    if ! is_brew_exists; then
        echo "Error: Homebrew is not installed"
        exit 1
    fi

    local brewfile="${HOME}/.Brewfile"

    if [ ! -f "$brewfile" ]; then
        echo "Warning: Brewfile not found at ${brewfile}"
        echo "Make sure to run 'chezmoi apply' first"
        exit 1
    fi

    echo "Installing packages from Brewfile..."
    brew bundle --file="$brewfile"
}

function main() {
    install_brewfile
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
