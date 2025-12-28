#!/bin/bash

brew-dump-explicit() {
  local output="${1:-Brewfile}"

  {
    echo "# Taps"
    brew tap | sort | sed 's/^/tap "/' | sed 's/$/"/'
    echo ""
    echo "# Formulae (explicitly installed)"
    brew leaves | sort | sed 's/^/brew "/' | sed 's/$/"/'
    echo ""
    echo "# Casks"
    brew list --cask | sort | sed 's/^/cask "/' | sed 's/$/"/'
  } > "$output"

  echo "Generated explicit-only Brewfile: $output"
}

# Run the function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  brew-dump-explicit "$@"
fi
