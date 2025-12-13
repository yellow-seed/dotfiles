#!/usr/bin/env bats

@test ".shellcheckrc configuration file exists" {
    [ -f ".shellcheckrc" ]
}

@test "ShellCheck workflow exists" {
    [ -f ".github/workflows/shellcheck.yml" ]
}

@test "shellcheck is in Brewfile" {
    grep -q "brew \"shellcheck\"" "home/dot_Brewfile"
}

@test "ShellCheck VS Code extension is in Brewfile" {
    grep -q "vscode \"timonwong.shellcheck\"" "home/dot_Brewfile"
}

@test "shfmt is in mise config" {
    grep -q "shfmt" "home/dot_config/mise/config.toml"
}

@test "all shell scripts pass ShellCheck validation" {
    # Skip if shellcheck is not available
    if ! command -v shellcheck &>/dev/null; then
        skip "ShellCheck is not installed"
    fi
    
    # Find all shell scripts and run ShellCheck
    run shellcheck \
        install/macos/common/brew.sh \
        install/macos/common/brewfile.sh \
        install/template.sh \
        scripts/macos/run_unit_test.sh \
        scripts/run_tests.sh \
        scripts/run_unit_test_common.sh \
        scripts/ubuntu/run_unit_test.sh \
        setup.sh
    
    [ "$status" -eq 0 ]
}
