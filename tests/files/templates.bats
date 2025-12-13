#!/usr/bin/env bats

# テスト用のセットアップ関数
setup() {
    # テスト環境のホームディレクトリを取得
    if [ -n "$HOME" ]; then
        TEST_HOME="$HOME"
    else
        TEST_HOME="/tmp/test_home"
        mkdir -p "$TEST_HOME"
    fi
}

@test ".chezmoi.toml.tmpl exists" {
    [ -f "home/.chezmoi.toml.tmpl" ]
}

@test ".chezmoi.toml.tmpl contains data section" {
    grep -q "\[data\]" home/.chezmoi.toml.tmpl
}

@test ".chezmoi.toml.tmpl contains name variable" {
    grep -q "name = " home/.chezmoi.toml.tmpl
}

@test ".chezmoi.toml.tmpl contains email variable" {
    grep -q "email = " home/.chezmoi.toml.tmpl
}

@test ".chezmoi.toml.tmpl contains isMac OS detection" {
    grep -q "isMac" home/.chezmoi.toml.tmpl
}

@test ".chezmoi.toml.tmpl contains isLinux OS detection" {
    grep -q "isLinux" home/.chezmoi.toml.tmpl
}

@test "gitconfig template exists" {
    [ -f "home/dot_gitconfig.tmpl" ]
}

@test "gitconfig template uses name variable" {
    grep -q "name = {{ .name }}" home/dot_gitconfig.tmpl
}

@test "gitconfig template uses email variable" {
    grep -q "email = {{ .email }}" home/dot_gitconfig.tmpl
}

@test "gitconfig template contains OS-specific credential helper for darwin" {
    grep -q "osxkeychain" home/dot_gitconfig.tmpl
}

@test "gitconfig template contains OS-specific credential helper for linux" {
    grep -q "cache --timeout" home/dot_gitconfig.tmpl
}

@test "gitconfig template uses OS detection for darwin" {
    grep -q 'if eq .chezmoi.os "darwin"' home/dot_gitconfig.tmpl
}

@test "gitconfig template uses OS detection for linux" {
    grep -q 'if eq .chezmoi.os "linux"' home/dot_gitconfig.tmpl
}

@test "zshrc template exists" {
    [ -f "home/dot_zshrc.tmpl" ]
}

@test "zshrc template contains OS-specific PNPM_HOME for darwin" {
    grep -q "Library/pnpm" home/dot_zshrc.tmpl
}

@test "zshrc template contains OS-specific PNPM_HOME for linux" {
    grep -q ".local/share/pnpm" home/dot_zshrc.tmpl
}

@test "zshrc template uses OS detection" {
    grep -q 'if eq .chezmoi.os' home/dot_zshrc.tmpl
}

# 実際の適用後のファイルをテストする場合（CIでchezmoiが適用された後）
@test "gitconfig contains user name if applied" {
    skip "Requires chezmoi apply to be run first"
    [ -f "$TEST_HOME/.gitconfig" ]
    grep -q "name = " "$TEST_HOME/.gitconfig"
}

@test "gitconfig contains appropriate credential helper if applied" {
    skip "Requires chezmoi apply to be run first"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        grep -q "osxkeychain" "$TEST_HOME/.gitconfig"
    else
        grep -q "cache" "$TEST_HOME/.gitconfig"
    fi
}

@test "zshrc contains appropriate PNPM_HOME if applied" {
    skip "Requires chezmoi apply to be run first"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        grep -q "Library/pnpm" "$TEST_HOME/.zshrc"
    else
        grep -q ".local/share/pnpm" "$TEST_HOME/.zshrc"
    fi
}
