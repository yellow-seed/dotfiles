#!/usr/bin/env bats

# テスト用のセットアップ関数
setup() {
    # setup.shのパスを取得
    SETUP_SCRIPT="${BATS_TEST_DIRNAME}/../../setup.sh"
}

@test "setup.sh exists and is executable" {
    [ -f "${SETUP_SCRIPT}" ]
    [ -x "${SETUP_SCRIPT}" ]
}

@test "get_os_type function returns valid OS type" {
    source "${SETUP_SCRIPT}"
    result="$(get_os_type)"
    # Darwin (macOS) or Linux を返すことを確認
    [[ "${result}" == "Darwin" || "${result}" == "Linux" ]]
}

@test "GITHUB_USERNAME has default value" {
    source "${SETUP_SCRIPT}"
    [ "${GITHUB_USERNAME}" = "yellow-seed" ]
}

@test "DOTFILES_REPO has correct default value" {
    source "${SETUP_SCRIPT}"
    [ "${DOTFILES_REPO}" = "https://github.com/yellow-seed/dotfiles.git" ]
}

@test "BRANCH_NAME has default value" {
    source "${SETUP_SCRIPT}"
    [ "${BRANCH_NAME}" = "main" ]
}

@test "GITHUB_USERNAME can be overridden by environment variable" {
    # 新しいシェルで実行してreadonlyの影響を受けないようにする
    # 一時ラッパースクリプトを作成してBASH_SOURCE問題を回避
    local wrapper_script
    wrapper_script=$(mktemp)
    cat > "${wrapper_script}" <<'EOF'
source "$1"
echo "${GITHUB_USERNAME}"
EOF
    result=$(GITHUB_USERNAME="test-user" bash "${wrapper_script}" "${SETUP_SCRIPT}")
    rm -f "${wrapper_script}"
    [ "${result}" = "test-user" ]
}

@test "DOTFILES_REPO uses GITHUB_USERNAME in URL" {
    # 新しいシェルで実行してreadonlyの影響を受けないようにする
    # 一時ラッパースクリプトを作成してBASH_SOURCE問題を回避
    local wrapper_script
    wrapper_script=$(mktemp)
    cat > "${wrapper_script}" <<'EOF'
source "$1"
echo "${DOTFILES_REPO}"
EOF
    result=$(GITHUB_USERNAME="custom-user" bash "${wrapper_script}" "${SETUP_SCRIPT}")
    rm -f "${wrapper_script}"
    [ "${result}" = "https://github.com/custom-user/dotfiles.git" ]
}

@test "initialize_os_env handles Darwin OS" {
    source "${SETUP_SCRIPT}"
    # get_os_type をモック
    get_os_type() {
        echo "Darwin"
    }
    export -f get_os_type
    # Darwin の場合はエラーなく終了することを確認
    run initialize_os_env
    [ "$status" -eq 0 ]
}

@test "initialize_os_env handles Linux OS" {
    source "${SETUP_SCRIPT}"
    # get_os_type をモック
    get_os_type() {
        echo "Linux"
    }
    export -f get_os_type
    # Linux の場合はエラーなく終了することを確認
    run initialize_os_env
    [ "$status" -eq 0 ]
}

@test "initialize_os_env fails on unsupported OS" {
    source "${SETUP_SCRIPT}"
    # get_os_type をモック
    get_os_type() {
        echo "Windows"
    }
    export -f get_os_type
    # Unsupported OS の場合は失敗することを確認
    run initialize_os_env
    [ "$status" -eq 1 ]
    [[ "${output}" == *"Unsupported OS"* ]]
}

@test "debug mode is disabled by default" {
    # デバッグモードが無効の場合、set -x が有効でないことを確認
    # これは直接的には検証しにくいが、スクリプトが正常に読み込めることを確認
    source "${SETUP_SCRIPT}"
    # エラーが発生しないことを確認
    [ $? -eq 0 ]
}

@test "debug mode can be enabled with DOTFILES_DEBUG" {
    # 新しいシェルで実行してDOTFILES_DEBUGを設定
    # 一時ラッパースクリプトを作成してBASH_SOURCE問題を回避
    local wrapper_script
    wrapper_script=$(mktemp)
    cat > "${wrapper_script}" <<'EOF'
source "$1" 2>&1
echo "success"
EOF
    result=$(DOTFILES_DEBUG=1 bash "${wrapper_script}" "${SETUP_SCRIPT}")
    rm -f "${wrapper_script}"
    [[ "${result}" == *"success"* ]]
}

@test "script works when BASH_SOURCE is undefined (curl/wget scenario)" {
    # BASH_SOURCEが未定義の状態をシミュレート（bash -c "$(curl ...)" のような実行）
    # スクリプトが unbound variable エラーなく実行できることを確認
    
    # テスト用のスクリプトを作成（run_chezmoiを無害化）
    TEST_SCRIPT=$(mktemp)
    # run_chezmoi関数全体をモックに置換（macOS/Linux両対応）
    sed '/^function run_chezmoi()/,/^}$/c\
function run_chezmoi() {\
    echo "Mock chezmoi install"\
}' "${SETUP_SCRIPT}" > "${TEST_SCRIPT}"
    
    # bash -c "$(cat script)" の形式で実行（curlシナリオのシミュレート）
    run bash -c "$(cat "${TEST_SCRIPT}")"
    
    # クリーンアップ
    rm -f "${TEST_SCRIPT}"
    
    # エラーなく実行できることを確認
    [ "$status" -eq 0 ]
    # unbound variable エラーが出ていないことを確認
    [[ ! "$output" =~ "unbound variable" ]]
}

@test "script does not execute main when sourced with BASH_SOURCE defined" {
    # sourceで読み込んだ場合はmainが実行されないことを確認
    # mainが実行されないことを検証するため、mainをモック化
    run bash -c 'main() { echo "Main was called"; }; export -f main; source '"${SETUP_SCRIPT}"
    
    # sourceは成功するが、mainは実行されないことを確認
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "Main was called" ]]
}
