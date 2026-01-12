# AGENTS.md - GitHub Copilot Agent Guide

## プロジェクト概要

このリポジトリは**dotfiles**管理システムで、[chezmoi](https://www.chezmoi.io/)を使用して個人の開発環境設定を管理しています。主な目的は、複数のマシン間で一貫した開発環境を維持し、新しいマシンでの環境構築を自動化することです。

### 主要な管理ツール

1. **chezmoi**: dotfiles全体の運用管理
   - 設定ファイルのバージョン管理と同期
   - テンプレート機能による環境別の設定
2. **Homebrew**: macOSアプリケーション管理
   - GUIアプリケーションとシステムツールのインストール
   - Brewfileによる一括管理

3. **mise**: プログラミング言語とCLIツールの管理
   - 複数言語のバージョン管理（Node.js, Python, Go, Rubyなど）
   - プロジェクト固有のツール管理

## リポジトリ構造

```bash
.
├── .chezmoiroot              # chezmoiのルートディレクトリ指定
├── .github/                  # GitHub Actions ワークフロー
│   └── workflows/
│       ├── copilot-setup-steps.yml  # Copilot検証環境構築
│       ├── test_bats.yml            # BATS単体テスト
│       └── test_chezmoi_apply.yml   # chezmoi適用テスト
├── home/                     # chezmoi管理下のdotfiles
│   ├── .chezmoi.toml.tmpl   # chezmoiメイン設定
│   ├── .chezmoiignore       # chezmoi無視ファイル
│   ├── dot_Brewfile         # Homebrewパッケージ定義
│   ├── dot_config/          # アプリケーション設定
│   │   ├── gh/             # GitHub CLI設定
│   │   └── mise/           # mise設定
│   │       └── config.toml  # miseツール定義
│   ├── dot_gitconfig        # Git設定
│   ├── dot_gitignore_global # Gitグローバル無視設定
│   └── dot_zshrc            # Zsh設定
├── install/                 # インストールスクリプト
│   ├── macos/
│   │   └── common/
│   │       ├── brew.sh      # Homebrew自動インストール
│   │       ├── brewfile.sh  # Brewfile自動適用
│   │       └── Brewfile     # Homebrewパッケージ定義（旧版）
│   └── ubuntu/
├── scripts/                 # ユーティリティスクリプト
│   ├── macos/
│   │   └── run_unit_test.sh  # macOS用テスト実行
│   ├── ubuntu/
│   │   └── run_unit_test.sh  # Ubuntu用テスト実行
│   └── run_unit_test_common.sh
├── tests/                   # 自動テストスイート
│   ├── files/
│   │   └── common.bats      # 共通ファイルテスト
│   └── install/
│       └── macos/
│           └── common/
│               ├── brew.bats     # Homebrewテスト
│               └── brewfile.bats # Brewfileテスト
├── setup.sh                 # クイックセットアップスクリプト
└── README.md                # ユーザー向けドキュメント
```

## 主要ファイルとディレクトリの詳細

### 設定ファイル (home/)

- **dot_Brewfile**: Homebrewでインストールするパッケージのリスト
  - brew: CLIツール
  - cask: GUIアプリケーション
  - mas: Mac App Storeアプリ
  - vscode: VS Code拡張機能

- **dot_config/mise/config.toml**: miseで管理する開発ツール
  - 言語ランタイム: Node.js, Python, Go, Ruby
  - CLIツール: act, aws-sam-cli, awscli, chezmoi, docker-compose, gh, pnpm, uv

- **dot_zshrc**: Zshシェル設定
  - miseの初期化設定を含む
  - 環境変数とエイリアスの定義

- **dot_gitconfig**: Git設定
  - ユーザー情報、エイリアス、デフォルト動作

### インストールスクリプト (install/)

- **macos/common/brew.sh**: Homebrewの自動インストール
- **macos/common/brewfile.sh**: Brewfileからパッケージを一括インストール
- **template.sh**: 新しいインストールスクリプトのテンプレート

### テストスイート (tests/)

- **BATS (Bash Automated Testing System)** を使用
- macOSとUbuntuの両方でテストを実行
- インストールスクリプトと設定ファイルの検証

## セットアップ手順

### 新しいマシンでの初期セットアップ

1. **chezmoiのインストールとdotfilesの適用**:

   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yellow-seed
   ```

2. **Homebrewのインストール** (macOSのみ):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Brewfileからパッケージをインストール** (macOSのみ):

   ```bash
   cd ~/.local/share/chezmoi
   brew bundle install --file=home/dot_Brewfile
   ```

4. **miseでツールをインストール**:

   ```bash
   mise install
   ```

### クイックセットアップ

リポジトリの`setup.sh`を使用:

```bash
sh setup.sh
```

## Claude Code での開発環境

### GitHub CLI (gh) のセットアップ

Claude Code on the Web などのリモート環境で GitHub CLI (`gh`) コマンドを使用する場合は、以下のhookスクリプトを実行してください：

```bash
bash .claude/hooks/gh-setup.sh
```

### リモート環境での gh コマンド使用方法

gitのremoteがローカルプロキシを経由している環境では、`gh` コマンドがリポジトリを自動認識できない場合があります。その場合は以下の方法を使用してください：

**方法: `-R` フラグでリポジトリを明示的に指定**

```bash
# Issue一覧を表示
gh issue list -R yellow-seed/dotfiles

# PR詳細を表示
gh pr view 123 -R yellow-seed/dotfiles
```

## 開発とテスト方法

### ローカルテスト実行

#### macOSでテスト実行

```bash
bash scripts/macos/run_unit_test.sh
```

#### Ubuntuでテスト実行

```bash
bash scripts/ubuntu/run_unit_test.sh
```

### BATSテストの書き方

テストファイルは`tests/`ディレクトリに配置:

```bash
#!/usr/bin/env bats

@test "テストケース名" {
  run コマンド
  [ "$status" -eq 0 ]
  [[ "$output" =~ "期待される出力" ]]
}
```

## テストファーストなシェルスクリプト実装

このリポジトリでは、**BATS (Bash Automated Testing System)** を使用したテストファースト開発を推奨しています。新しいインストールスクリプトやユーティリティを追加する際は、必ず先にテストを書いてから実装を行います。

### テストファースト開発の流れ

#### 1. テストファイルの作成（Red フェーズ）

まず、期待する動作を定義するテストを書きます。この時点でテストは失敗します。

**例**: 新しいインストールスクリプト `install/macos/common/git.sh` のテスト作成

```bash
# tests/install/macos/common/git.bats
#!/usr/bin/env bats

@test "git installation script exists" {
    [ -f "install/macos/common/git.sh" ]
}

@test "git installation script is executable" {
    [ -x "install/macos/common/git.sh" ]
}

@test "git installation script has proper error handling" {
    run head -1 install/macos/common/git.sh
    [[ "$output" =~ "#!/usr/bin/env bash" ]] || [[ "$output" =~ "#!/bin/bash" ]]
}

@test "git installation script uses set -Eeuo pipefail" {
    run grep "set -Eeuo pipefail" install/macos/common/git.sh
    [ "$status" -eq 0 ]
}

@test "git installation script runs without errors in dry-run mode" {
    # 環境変数でドライランモードを有効化
    DRY_RUN=true run bash install/macos/common/git.sh
    [ "$status" -eq 0 ]
}

@test "git command is available after installation" {
    skip "Requires actual installation, test in CI only"
    run command -v git
    [ "$status" -eq 0 ]
}
```

#### 2. テストの実行と確認（Red フェーズ）

```bash
# macOSの場合
bash scripts/macos/run_unit_test.sh

# Ubuntuの場合
bash scripts/ubuntu/run_unit_test.sh
```

この段階では、スクリプトがまだ存在しないため、テストは失敗します。

#### 3. 実装（Green フェーズ）

テストをパスする最小限の実装を行います。

```bash
# install/macos/common/git.sh
#!/usr/bin/env bash

# エラーハンドリング設定
set -Eeuo pipefail

# 環境変数の設定
DRY_RUN="${DRY_RUN:-false}"

# Gitがインストール済みかチェック
if command -v git >/dev/null 2>&1; then
    echo "Git is already installed"
    git --version
    exit 0
fi

# ドライランモードの場合は実際のインストールをスキップ
if [ "$DRY_RUN" = "true" ]; then
    echo "[DRY RUN] Would install git"
    exit 0
fi

# Gitをインストール
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing git via Homebrew..."
    brew install git
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Git installation completed"
git --version
```

#### 4. テストの再実行（Green フェーズ）

実装後、テストを再実行してすべてパスすることを確認します。

```bash
bash scripts/macos/run_unit_test.sh
```

#### 5. リファクタリング（Refactor フェーズ）

テストがパスしたら、コードの品質を向上させます：

- 重複コードの削除
- 関数への分割
- コメントの追加
- エラーメッセージの改善

各リファクタリング後は必ずテストを再実行し、動作が壊れていないことを確認します。

### BATSテストのベストプラクティス

#### テストの構造

```bash
#!/usr/bin/env bats

# セットアップ処理（各テスト実行前）
setup() {
    # テスト用の一時ディレクトリを作成
    export TEST_TEMP_DIR="$(mktemp -d)"
}

# クリーンアップ処理（各テスト実行後）
teardown() {
    # 一時ディレクトリを削除
    [ -d "$TEST_TEMP_DIR" ] && rm -rf "$TEST_TEMP_DIR"
}

@test "スクリプトが存在する" {
    [ -f "install/macos/common/script.sh" ]
}

@test "スクリプトが実行可能" {
    [ -x "install/macos/common/script.sh" ]
}

@test "エラーハンドリングが設定されている" {
    run grep "set -Eeuo pipefail" install/macos/common/script.sh
    [ "$status" -eq 0 ]
}

@test "環境変数のデフォルト値が設定されている" {
    run grep 'VARIABLE="${ENVIRONMENT_VAR:-default_value}"' install/macos/common/script.sh
    [ "$status" -eq 0 ]
}
```

#### テストケースの分類

1. **存在確認テスト**: ファイルやディレクトリの存在を確認
2. **権限テスト**: 実行可能権限などを確認
3. **構文テスト**: エラーハンドリングや変数定義の確認
4. **機能テスト**: 実際の動作を確認（ドライランモードを活用）
5. **統合テスト**: 複数のスクリプトの連携を確認

#### ドライランモードの実装

実際にシステムを変更せずにテストするために、ドライランモードを実装します：

```bash
# スクリプト内
DRY_RUN="${DRY_RUN:-false}"

if [ "$DRY_RUN" = "true" ]; then
    echo "[DRY RUN] Would execute: brew install package"
    exit 0
fi

# 実際のコマンド
brew install package
```

```bash
# テスト内
@test "ドライランモードで正常に動作する" {
    DRY_RUN=true run bash install/macos/common/script.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ "\[DRY RUN\]" ]]
}
```

### 実装時の重点ポイント

1. **テストを先に書く**: コードを書く前に、期待する動作を定義する
2. **小さく始める**: 最小限の機能から始めて、段階的に拡張する
3. **頻繁にテストする**: コード変更のたびにテストを実行する
4. **エッジケースを考える**: 正常系だけでなく、異常系もテストする
5. **CI/CDで自動化**: GitHub Actionsで自動的にテストを実行する

### テスト実行コマンド

```bash
# すべてのテストを実行
bats tests/

# 特定のテストファイルのみ実行
bats tests/install/macos/common/brew.bats
```

### テストカバレッジの確認

このリポジトリでは、**bashcov**（SimpleCov-based coverage tool）を使用してBashスクリプトのテストカバレッジを計測し、**Codecov**で可視化しています。

カバレッジツールの特徴

- **bashcov**: RubyGems経由でインストール可能なBashカバレッジツール
  - SimpleCovベースの成熟したツール
  - JSON形式でのレポート生成（Codecov連携）
  - CI/CD環境のみでインストール（dotfiles本体には依存なし）

### テスト環境の優先順位

**重要**: このリポジトリでは、macOSを主要な開発・運用環境としているため、テスト検証とカバレッジ拡充は**macOSを優先**します。

- **macOS**: 主要環境であり、テストパターンの拡充と検証を優先的に実施
  - 新しいインストールスクリプトやツールの追加時は、まずmacOS環境でのテストを充実させる
  - カバレッジの向上もmacOS環境を優先して取り組む
  - ローカル開発環境として実際に使用されるため、実践的なテストが重要

- **Ubuntu**: サブ環境であり、CI/CD環境での動作確認が主目的
  - 現状、実運用では使用していない
  - 基本的な動作確認レベルのテストで十分
  - macOS環境のテストが充実した後に、必要に応じて拡充

この優先順位により、実際の利用シーンに即した高品質なテストカバレッジを維持します。

### CI/CDワークフロー

1. **test_bats.yml**: macOSとUbuntuでBATSテストを実行（カバレッジなし、高速実行）
2. **coverage.yml**: bashcovによるカバレッジ計測とCodecovへのレポート送信
3. **test_chezmoi_apply.yml**: chezmoiの適用が正常に動作するか検証
4. **shellcheck.yml**: ShellCheckによるシェルスクリプトの静的解析
5. **copilot-setup-steps.yml**: GitHub Copilot用の検証環境構築

## コード品質管理

### Lintツール

#### ShellCheck

- **目的**: シェルスクリプトの静的解析
- **検出内容**: 文法エラー、潜在的なバグ、非推奨な書き方
- **設定ファイル**: `.shellcheckrc`
- **インストール**:

  ```bash
  # macOS
  brew install shellcheck
  
  # Ubuntu
  sudo apt-get install shellcheck
  ```

- **実行方法**:

  ```bash
  # ローカルでの実行
  shellcheck script.sh
  
  # すべてのスクリプトを一括チェック
  shellcheck install/**/*.sh scripts/**/*.sh setup.sh
  ```

- **CI統合**: `.github/workflows/ci-macos.yml`、`.github/workflows/ci-ubuntu.yml`で自動実行

#### shfmt

- **目的**: シェルスクリプトの自動フォーマット
- **インストール**:

  ```bash
  # mise経由（推奨）
  mise use shfmt@latest
  
  # または Homebrew
  brew install shfmt
  ```

- **実行方法**:

  ```bash
  # チェックのみ
  shfmt -d -i 2 .
  
  # 自動フォーマット
  shfmt -w -d -i 2 .
  ```

- **CI統合**: `.github/workflows/ci-macos.yml`、`.github/workflows/ci-ubuntu.yml`で自動実行

## コーディング規約とベストプラクティス

### Bashスクリプト

1. **エラーハンドリング**:

   ```bash
   set -Eeuo pipefail
   ```

   - `-E`: ERRトラップを関数に継承
   - `-e`: エラー時に即座に終了
   - `-u`: 未定義変数をエラーとする
   - `-o pipefail`: パイプライン内のエラーを検出

2. **変数の命名**:
   - 環境変数: `UPPER_CASE`
   - ローカル変数: `lower_case`

3. **デフォルト値の設定**:

   ```bash
   VARIABLE="${ENVIRONMENT_VAR:-default_value}"
   ```

4. **ShellCheckによる静的解析**:
   - すべてのシェルスクリプトは[ShellCheck](https://www.shellcheck.net/)で検証されます
   - CI/CDパイプラインで自動チェックが実行されます
   - ローカルでの検証方法:

     ```bash
     # 単一ファイルをチェック
     shellcheck install/macos/common/brew.sh
     
     # すべてのシェルスクリプトをチェック
     shellcheck **/*.sh
     
     # shfmtでフォーマット
     shfmt -w .
     ```

   - VS Code拡張機能を使用すると、エディタ内でリアルタイム検証が可能
   - `.shellcheckrc`でプロジェクト固有のルールを設定可能

### Git コミットメッセージ

[Conventional Commits](https://www.conventionalcommits.org/)形式を使用:

- `feat:` - 新機能追加
- `fix:` - バグ修正
- `chore:` - 雑務（既存設定の反映など）
- `docs:` - ドキュメント更新
- `test:` - テスト追加・修正

### ブランチ戦略

- `main`: 安定版
- `feature/*`: 新機能開発
- `fix/*`: バグ修正
- `chore/*`: メンテナンス作業
- `docs/*`: ドキュメント更新

## ツール管理のワークフロー

### Homebrewパッケージの追加

```bash
# パッケージをインストール
brew install <package-name>

# Brewfileを更新
brew bundle dump --describe --force --file=~/.local/share/chezmoi/home/dot_Brewfile

# chezmoiに反映
chezmoi re-add ~/.Brewfile

# コミットしてプッシュ
git add .
git commit -m "chore: <package-name>をBrewfileに追加"
git push
```

### miseツールの追加

```bash
# ツールをインストール
mise use node@20.0.0

# chezmoiに反映
chezmoi re-add ~/.config/mise/config.toml

# コミットしてプッシュ
git add .
git commit -m "chore: Node.js 20.0.0をmiseに追加"
git push
```

### dotfilesの追加・更新

```bash
# 新しい設定ファイルを追加
chezmoi add ~/.newconfig

# 既存の設定ファイルを更新
chezmoi re-add ~/.existingconfig

# 変更を確認
chezmoi diff

# 変更を適用
chezmoi apply

# コミットしてプッシュ
git add .
git commit -m "feat: 新しい設定ファイルを追加"
git push
```

## GitHub Copilotエージェント向けの重要情報

### コンテキスト理解のポイント

1. **ツールの優先順位**:
   - chezmoi: 設定ファイル管理（最優先）
   - Homebrew: macOSアプリケーション管理
   - mise: 開発言語・ツール管理

2. **ディレクトリ構造の重要性**:
   - `home/`: chezmoiのソースディレクトリ（設定ファイルの実体）
   - ファイル名の`dot_`プレフィックスは`.`に変換される
   - テンプレートファイル（`.tmpl`拡張子）は環境変数を展開

3. **変更時の注意点**:
   - 設定ファイルは必ず`chezmoi add`または`chezmoi re-add`で管理
   - 直接ホームディレクトリを編集せず、`chezmoi edit`を使用
   - Brewfile更新時は`brew bundle dump`を実行

4. **PR作成時の必須事項（Chezmoi設定変更の場合）**:
   - Chezmoiの設定変更（テンプレートファイルや設定ファイルの追加・変更）を含むPRでは、必ず以下を実施しPRに記載すること：
     - `chezmoi apply --dry-run --verbose` の実行結果を提示
     - または `chezmoi diff` の出力を提示
     - テンプレートファイル（`.tmpl`）の場合は、`chezmoi execute-template` で展開結果を提示
     - 複数OS対応の場合は、各OS（macOS/Linux）での展開結果を明示
   - これにより、変更内容が実際の環境でどのように適用されるかをレビュアーが確認できる

5. **テスト必須事項**:
   - スクリプト変更時は必ずBATSテストを実行
   - CI/CDワークフローで自動テストが実行される
   - macOSとUbuntuの両環境をサポート

### よくある作業パターン

1. **新しい設定ファイルの追加**:
   - ホームディレクトリに設定ファイルを作成
   - `chezmoi add ~/.config/newapp/config.yml`
   - `git commit` & `git push`

2. **Homebrewパッケージの管理**:
   - `brew install`/`brew uninstall`でパッケージを操作
   - `brew bundle dump`でBrewfileを更新
   - `chezmoi re-add ~/.Brewfile`でchezmoiに反映

3. **開発ツールのバージョン管理**:
   - `mise use <tool>@<version>`でツールを追加
   - `chezmoi re-add ~/.config/mise/config.toml`で反映

### トラブルシューティング

- **chezmoi適用エラー**: `chezmoi diff`で差分を確認
- **Homebrew依存関係エラー**: `brew doctor`で診断
- **miseインストールエラー**: `mise doctor`で環境チェック
- **テスト失敗**: ログを確認し、該当スクリプトを修正

## 参考リンク

- [chezmoi公式ドキュメント](https://www.chezmoi.io/)
- [Homebrew公式サイト](https://brew.sh/)
- [mise公式ドキュメント](https://mise.jdx.dev/)
- [BATS公式リポジトリ](https://github.com/bats-core/bats-core)
- [Conventional Commits仕様](https://www.conventionalcommits.org/)
