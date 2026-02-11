# AGENTS.md - GitHub Copilot Agent Guide

## プロジェクト概要

このリポジトリは**dotfiles**管理システムで、[chezmoi](https://www.chezmoi.io/)を使用して個人の開発環境設定を管理しています。主な目的は、複数のマシン間で一貫した開発環境を維持し、新しいマシンでの環境構築を自動化することです。

### 主要な管理ツール

1. **chezmoi**: dotfiles全体の運用管理
   - 設定ファイルのバージョン管理と同期
   - テンプレート機能による環境別の設定
2. **Homebrew**: macOSアプリケーション管理

   - GUIアプリケーションとシステムツールのインストール
   - スクリプト内でパッケージリストを直接管理

3. **mise**: プログラミング言語とCLIツールの管理
   - 複数言語のバージョン管理（Node.js, Python, Go, Rubyなど）
   - プロジェクト固有のツール管理

## リポジトリ構造

```bash
.
├── .chezmoiroot              # chezmoiのルートディレクトリ指定
├── .github/                  # GitHub Actions ワークフロー
│   └── workflows/
│       ├── ci-macos.yml             # macOS CI/CD
│       ├── ci-ubuntu.yml            # Ubuntu CI/CD
│       ├── ci-windows.yml           # Windows CI/CD
│       ├── copilot-setup-steps.yml  # Copilot検証環境構築
│       └── e2e-setup-test.yml       # E2Eセットアップテスト
├── home/                     # chezmoi管理下のdotfiles
│   ├── .chezmoi.toml.tmpl   # chezmoiメイン設定
│   ├── .chezmoiignore       # chezmoi無視ファイル
│   ├── dot_config/          # アプリケーション設定
│   │   ├── gh/             # GitHub CLI設定
│   │   └── mise/           # mise設定
│   │       └── config.toml  # miseツール定義
│   ├── dot_gitconfig        # Git設定
│   ├── dot_gitignore_global # Gitグローバル無視設定
│   └── dot_zshrc            # Zsh設定
├── install/                 # インストールスクリプト（テストと実装が同じ階層）
│   ├── common/              # OS共通
│   │   └── chezmoi.bats    # chezmoiテスト
│   ├── macos/              # macOS専用
│   │   ├── 01-brew.sh      # Homebrew自動インストール
│   │   ├── 01-brew.bats    # Homebrewテスト
│   │   ├── 02-brew-packages.sh  # パッケージ自動インストール
│   │   ├── 02-brew-packages.bats # パッケージインストールテスト
│   │   ├── 03-profile.sh  # プロファイル固有パッケージインストール
│   │   ├── 03-profile.bats # プロファイル固有パッケージテスト
│   │   ├── setup.sh       # macOS用オーケストレーター
│   │   ├── setup.bats     # macOS用オーケストレーターテスト
│   │   ├── Brewfile        # Homebrewパッケージ定義
│   │   ├── brew-dump-explicit.sh    # Brewfileダンプスクリプト
│   │   ├── brew-dump-explicit.bats  # Brewfileダンプテスト
│   │   ├── work/           # 仕事環境用Brewfile
│   │   │   └── Brewfile
│   │   └── private/        # プライベート環境用Brewfile
│   │       └── Brewfile
│   ├── ubuntu/             # Ubuntu専用（仮実装/Stub）
│   │   └── README.md       # 仮実装の説明
│   └── windows/            # Windows専用
│       ├── 01-winget.ps1           # Wingetインストール
│       ├── 01-winget.Tests.ps1     # Wingetテスト
│       ├── 02-dev-tools.ps1        # 開発ツールインストール
│       ├── 02-dev-tools.Tests.ps1  # 開発ツールテスト
│       ├── 03-packages.ps1         # パッケージインストール
│       ├── 03-packages.Tests.ps1   # パッケージテスト
│       ├── packages.json           # パッケージ定義
│       ├── run_unit_test.ps1       # Windows用テスト実行
│       ├── setup.ps1               # Windows用オーケストレーター
│       └── setup.Tests.ps1         # Windows用オーケストレーターテスト
├── docker/                  # OS別Dockerテスト環境
│   ├── macos-test/          # macOSスクリプト用テスト環境
│   │   ├── Dockerfile
│   │   ├── docker-compose.yml
│   │   └── lint-shell
│   ├── ubuntu-test/         # Ubuntuスクリプト用テスト環境
│   │   ├── Dockerfile
│   │   ├── docker-compose.yml
│   │   └── lint-shell
│   └── windows-test/        # Windowsスクリプト用テスト環境
│       ├── Dockerfile
│       └── docker-compose.yml
├── tests/                   # ファイル系のテストのみ
│   └── files/
│       ├── common.bats      # 共通ファイルテスト
│       ├── shellcheck.bats  # ShellCheckテスト
│       ├── templates.bats   # テンプレートテスト
│       └── setup.bats       # セットアップテスト
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

### Dockerテスト環境 (docker/)

一般的なリポジトリではDockerfileやdocker-compose.ymlはリポジトリルートに配置されますが、このリポジトリでは`docker/`ディレクトリの下にOS別に分けて配置しています。これは、dotfilesリポジトリが複数OS（macOS/Ubuntu/Windows）のセットアップスクリプトを1つのリポジトリで管理しているため、テスト環境もOS別に分離する必要があるためです。

各テスト環境はリポジトリ全体を`/workspace`にマウントし、対応するOS向けのテスト・Lint・カバレッジ計測を実行します。

- **macos-test/**: macOS向けシェルスクリプトのテスト環境（Ubuntu 22.04ベース）

  - BATS、ShellCheck、shfmt、actionlint、kcovを含む
  - `lint-shell`: ShellCheckを全`.sh`/`.bash`ファイルに実行するスクリプト

- **ubuntu-test/**: Ubuntu向けシェルスクリプトのテスト環境

  - macos-testと同等のツールセット
  - `lint-shell`: macos-testと同等のLintスクリプト

- **windows-test/**: Windows向けPowerShellスクリプトのテスト環境
  - PowerShell Core（mcr.microsoft.com/powershell）ベース
  - Pester（テストフレームワーク）、PSScriptAnalyzer（静的解析）を含む
  - `windows-test`サービス（テスト実行）と`windows-test-shell`サービス（対話シェル）の2サービス構成

### インストールスクリプト (install/)

**新しい構造の特徴**：テストコードと実装コードが同じディレクトリに配置され、OS別に明確に分離されています。

#### OS共通 (common/)

- **chezmoi.bats**: chezmoiインストールスクリプトのテスト（実装はペンディング）
  - chezmoiはOS非依存のツールのため、common/に配置

#### macOS専用 (macos/)

- **01-brew.sh**: Homebrewの自動インストール
- **02-brew-packages.sh**: スクリプト内のパッケージリストからtap/formulae/caskを一括インストール
- **03-profile.sh**: プロファイル固有パッケージのインストール
- **setup.sh**: macOS用オーケストレーター
- **brew-dump-explicit.sh**: 明示的にインストールされたパッケージをBrewfileにダンプ
- 各スクリプトに対応する .bats テストファイル

#### Windows専用 (windows/)

- **01-winget.ps1**: Windows用パッケージマネージャー設定
- **02-dev-tools.ps1**: Windows用開発ツールインストール
- **03-packages.ps1**: Windows用パッケージ一括インストール
- **setup.ps1**: Windows用オーケストレーター
- 各スクリプトに対応する .Tests.ps1 テストファイル

#### Ubuntu専用 (ubuntu/)

- **現在は仮実装（Stub）**: 実用優先度が低いため、スクリプトは未実装
- 今後、必要に応じて実装予定

#### その他

- **template.sh**: 新しいインストールスクリプトのテンプレート

### テストスイート

**責務別の配置**：

- **install/\*/\*.bats, \*.Tests.ps1**: インストールスクリプトのテスト（実装と同じディレクトリ）
- **tests/files/**: ファイル系の共通テスト（ShellCheck、テンプレート検証など）

**テストフレームワーク**：

- **BATS (Bash Automated Testing System)**: macOS/Ubuntuのシェルスクリプトテスト
- **Pester**: Windows PowerShellスクリプトテスト
- macOS、Ubuntu、Windowsの3つのOS環境でCIが実行される

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
# すべてのテストを実行
bats install/macos/ install/common/ tests/files/

# 特定のテストのみ実行
bats install/macos/brew.bats
```

#### Ubuntuでテスト実行

```bash
# すべてのテストを実行
bats install/ubuntu/ install/common/ tests/files/

# 特定のテストのみ実行
bats install/common/chezmoi.bats
```

#### Windowsでテスト実行

```powershell
# すべてのテストを実行
.\install\windows\run_unit_test.ps1

# 特定のテストのみ実行
Invoke-Pester -Path install/windows/01-winget.Tests.ps1
```

### BATSテストの書き方

テストファイルは実装と同じディレクトリに配置（`install/*/`）、またはファイル系テストは `tests/files/` に配置:

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

**例**: 新しいインストールスクリプト `install/macos/git.sh` のテスト作成

```bash
# install/macos/git.bats
#!/usr/bin/env bats

@test "git installation script exists" {
    [ -f "install/macos/git.sh" ]
}

@test "git installation script is executable" {
    [ -x "install/macos/git.sh" ]
}

@test "git installation script has proper error handling" {
    run head -1 install/macos/git.sh
    [[ "$output" =~ "#!/usr/bin/env bash" ]] || [[ "$output" =~ "#!/bin/bash" ]]
}

@test "git installation script uses set -Eeuo pipefail" {
    run grep "set -Eeuo pipefail" install/macos/git.sh
    [ "$status" -eq 0 ]
}

@test "git installation script runs without errors in dry-run mode" {
    # 環境変数でドライランモードを有効化
    DRY_RUN=true run bash install/macos/git.sh
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
bats install/macos/git.bats

# Ubuntuの場合
bats install/ubuntu/git.bats
```

この段階では、スクリプトがまだ存在しないため、テストは失敗します。

#### 3. 実装（Green フェーズ）

テストをパスする最小限の実装を行います。

```bash
# install/macos/git.sh
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
bats install/macos/git.bats
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
# macOS: すべてのテストを実行
bats install/macos/ install/common/ tests/files/

# Ubuntu: すべてのテストを実行
bats install/ubuntu/ install/common/ tests/files/

# 特定のテストファイルのみ実行
bats install/macos/brew.bats
```

### テストカバレッジの確認

このリポジトリでは、**kcov**（C実装のカバレッジツール）を使用してBashスクリプトのテストカバレッジを計測し、**Codecov**で可視化しています。

カバレッジツールの特徴

- **kcov**: 低オーバーヘッドでBashを計測できるカバレッジツール
  - C実装で高速
  - Cobertura形式のレポート出力に対応（Codecov連携）
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
2. **coverage.yml**: kcovによるカバレッジ計測とCodecovへのレポート送信
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
     shellcheck install/macos/01-brew.sh

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

# install/macos/02-brew-packages.sh 内の該当配列（taps/formulae/casks）にパッケージを追加
# ※ 新しいマシンでのセットアップ時に自動インストールされるようにするため

# （任意）Brewfileをダンプして現在の状態を記録
bash install/macos/brew-dump-explicit.sh install/macos/Brewfile

# コミットしてプッシュ
git add install/macos/02-brew-packages.sh install/macos/Brewfile
git commit -m "chore: <package-name>を追加"
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
   - パッケージ追加・削除時は`install/macos/02-brew-packages.sh`の配列を更新

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
   - `install/macos/02-brew-packages.sh` 内の配列を更新
   - （任意）`brew-dump-explicit.sh`でBrewfileをダンプ

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
