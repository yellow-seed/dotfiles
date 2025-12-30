#!/opt/homebrew/bin/bash

# Generate a Brewfile containing only explicitly installed packages (no dependencies)
#
# Usage:
#   ./scripts/macos/brew-dump-explicit.sh [output_path]
#
# Arguments:
#   output_path - Path to the output file (default: Brewfile in current directory)
#
# Examples:
#   ./scripts/macos/brew-dump-explicit.sh                          # Creates ./Brewfile
#   ./scripts/macos/brew-dump-explicit.sh Brewfile.explicit        # Creates ./Brewfile.explicit
#   ./scripts/macos/brew-dump-explicit.sh ~/dotfiles/Brewfile      # Creates ~/dotfiles/Brewfile
#   ./scripts/macos/brew-dump-explicit.sh /tmp/test/Brewfile       # Creates /tmp/test/Brewfile

brew-dump-explicit() {
  local output="${1:-Brewfile}"
  local temp_file

  # If output is a directory, append default filename
  if [[ -d "$output" ]]; then
    output="${output%/}/Brewfile"
  fi

  # Create temporary file
  temp_file=$(mktemp)

  # Read existing comments and store them in an associative array
  declare -A package_comments

  if [[ -f "$output" ]]; then
    local comment_buffer=""
    while IFS= read -r line; do
      # If line is a comment, add to buffer
      if [[ "$line" =~ ^#[[:space:]].*$ ]]; then
        comment_buffer+="${line}"$'\n'
      # If line is a package entry (brew, cask, tap), save comment with package name
      elif [[ "$line" =~ ^(brew|cask|tap)[[:space:]]\"(.+)\" ]]; then
        local pkg_type="${BASH_REMATCH[1]}"
        local pkg_name="${BASH_REMATCH[2]}"
        if [[ -n "$comment_buffer" ]]; then
          package_comments["${pkg_type}:${pkg_name}"]="$comment_buffer"
          comment_buffer=""
        fi
      else
        comment_buffer=""
      fi
    done < "$output"
  fi

  # Generate new content
  {
    echo "# Taps"
    while IFS= read -r tap_name; do
      if [[ -n "${package_comments[tap:$tap_name]}" ]]; then
        printf "%s" "${package_comments[tap:$tap_name]}"
      fi
      echo "tap \"$tap_name\""
    done < <(brew tap | sort)

    echo ""
    echo "# Formulae (explicitly installed)"
    while IFS= read -r brew_name; do
      if [[ -n "${package_comments[brew:$brew_name]}" ]]; then
        printf "%s" "${package_comments[brew:$brew_name]}"
      fi
      echo "brew \"$brew_name\""
    done < <(brew leaves | sort)

    echo ""
    echo "# Casks"
    while IFS= read -r cask_name; do
      if [[ -n "${package_comments[cask:$cask_name]}" ]]; then
        printf "%s" "${package_comments[cask:$cask_name]}"
      fi
      echo "cask \"$cask_name\""
    done < <(brew list --cask | sort)

    # Preserve mas and go entries from existing Brewfile if it exists
    if [[ -f "$output" ]]; then
      if grep -q '^mas ' "$output"; then
        echo ""
        echo "# Mac App Store"
        grep '^mas ' "$output"
      fi

      if grep -q '^go ' "$output"; then
        echo ""
        echo "# Go packages"
        grep '^go ' "$output"
      fi
    fi
  } > "$temp_file"

  # Move temp file to output
  mv "$temp_file" "$output"

  echo "Generated explicit-only Brewfile: $output"
}

# Run the function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  brew-dump-explicit "$@"
fi
