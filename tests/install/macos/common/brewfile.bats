#!/usr/bin/env bats

@test "brewfile installation script exists" {
    [ -f "install/macos/common/brewfile.sh" ]
}

@test "brewfile installation script is executable" {
    [ -x "install/macos/common/brewfile.sh" ]
}

# 実際のインストールテストは時間がかかるため、
# 基本的な動作確認のみ
@test "brewfile script checks for brew command" {
    skip "Requires actual chezmoi setup"
    # このテストはE2Eテストで実行
}
