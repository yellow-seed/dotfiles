# dotfiles

<!-- CI/CD & Code Quality -->

[![CI - macOS](https://github.com/yellow-seed/dotfiles/workflows/CI%20-%20macOS/badge.svg)](https://github.com/yellow-seed/dotfiles/actions/workflows/ci-macos.yml)
[![CI - Ubuntu](https://github.com/yellow-seed/dotfiles/workflows/CI%20-%20Ubuntu/badge.svg)](https://github.com/yellow-seed/dotfiles/actions/workflows/ci-ubuntu.yml)
[![CI - Windows](https://github.com/yellow-seed/dotfiles/workflows/CI%20-%20Windows/badge.svg)](https://github.com/yellow-seed/dotfiles/actions/workflows/ci-windows.yml)
[![Actionlint](https://github.com/yellow-seed/dotfiles/workflows/Actionlint/badge.svg)](https://github.com/yellow-seed/dotfiles/actions/workflows/actionlint.yml)
[![codecov](https://codecov.io/gh/yellow-seed/dotfiles/branch/main/graph/badge.svg)](https://codecov.io/gh/yellow-seed/dotfiles)

<!-- Project Info -->

[![License](https://img.shields.io/github/license/yellow-seed/dotfiles)](https://github.com/yellow-seed/dotfiles/blob/main/LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/yellow-seed/dotfiles)](https://github.com/yellow-seed/dotfiles/commits/main)

<!-- Repository Activity -->

[![GitHub stars](https://img.shields.io/github/stars/yellow-seed/dotfiles)](https://github.com/yellow-seed/dotfiles/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/yellow-seed/dotfiles)](https://github.com/yellow-seed/dotfiles/network/members)
[![GitHub issues](https://img.shields.io/github/issues/yellow-seed/dotfiles)](https://github.com/yellow-seed/dotfiles/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/yellow-seed/dotfiles)](https://github.com/yellow-seed/dotfiles/pulls)

<!-- Other Workflows -->

[![Claude Code](https://github.com/yellow-seed/dotfiles/workflows/Claude%20Code/badge.svg)](https://github.com/yellow-seed/dotfiles/actions/workflows/claude.yml)
[![Copilot Setup Steps](https://github.com/yellow-seed/dotfiles/workflows/Copilot%20Setup%20Steps/badge.svg)](https://github.com/yellow-seed/dotfiles/actions/workflows/copilot-setup-steps.yml)

chezmoiを使用したdotfiles管理のガイドです。

## ディレクトリ構造

```bash
.
├── .chezmoiroot           # chezmoiのソースディレクトリを指定
├── home/                  # chezmoi管理下のdotfiles
│   ├── .chezmoi.toml.tmpl
│   ├── .chezmoiignore
│   ├── dot_Brewfile
│   ├── dot_config/
│   ├── dot_gitconfig.tmpl
│   ├── dot_gitignore_global
│   └── dot_zshrc.tmpl
├── .github/
└── README.md
```

`.chezmoiroot`ファイルによって、chezmoiは`home/`ディレクトリをソースディレクトリとして認識します。この構造により、将来的に`install/`（セットアップスクリプト）や`tests/`（自動テスト）などのディレクトリを追加することが可能になります。

## 管理ポリシー

このdotfilesリポジトリでは、以下の3つのツールを役割分担して使用しています：

### chezmoi

- **目的**: dotfiles全体の運用管理
- **管理対象**: 設定ファイル（`.zshrc`, `.gitconfig`, `.chezmoi.toml`など）
- **役割**: 設定ファイルのバージョン管理、複数環境での同期、設定の適用・更新

### Homebrew

- **目的**: グローバルに適用したいアプリケーションの管理
- **管理対象**: GUIアプリケーション、システム全体で使用するCLIツール
- **役割**: macOSアプリケーションのインストール・管理、スクリプト内でパッケージリストを直接管理

### mise

- **目的**: プログラミングに特化した言語とCLIの管理
- **管理対象**: プログラミング言語（Node.js, Python, Goなど）、開発用CLIツール
- **役割**: 言語バージョンの切り替え、プロジェクト固有のツール管理

## テンプレート機能

chezmoiのテンプレート機能を活用することで、環境やOS固有の設定を動的に管理できます。テンプレートファイルは`.tmpl`拡張子を持ち、Go の `text/template` シンタックスを使用します。

### テンプレート変数の管理

`.chezmoi.toml.tmpl`ファイルで変数を定義します：

```toml
[data]
    name = "your-name"
    email = "your-email@example.com"

    # OS固有の設定
    isMac = true    # macOSの場合はtrue、そうでなければfalse
    isLinux = false # Linuxの場合はtrue、そうでなければfalse
```

これらの変数は、他のテンプレートファイルから `{{ .name }}` や `{{ .email }}` のようにアクセスできます。

### OS固有の設定

テンプレート内で `{{ .chezmoi.os }}` を使用してOSを判定し、環境に応じた設定を適用できます：

#### gitconfig の例

`dot_gitconfig.tmpl` では、OSに応じて適切なcredential helperを設定：

```gitconfig
[user]
    name = {{ .name }}
    email = {{ .email }}

{{- if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}

{{- if eq .chezmoi.os "linux" }}
[credential]
    helper = cache --timeout=3600
{{- end }}
```

#### zshrc の例

`dot_zshrc.tmpl` では、OSに応じてPNPM_HOMEのパスを設定：

```bash
{{- if eq .chezmoi.os "darwin" }}
export PNPM_HOME="$HOME/Library/pnpm"
{{- else if eq .chezmoi.os "linux" }}
export PNPM_HOME="$HOME/.local/share/pnpm"
{{- end }}
```

### 初回セットアップ時の変数入力

`chezmoi init` 実行時に、テンプレート変数の値を対話的に入力できます：

```bash
chezmoi init --promptString name=your-name --promptString email=your-email@example.com
```

または、既存の`.chezmoi.toml.tmpl`の変数定義を直接編集することもできます。

### テンプレートのテスト

テンプレートが正しく展開されるかをテストできます：

```bash
# 特定のファイルのテンプレート展開結果を確認
chezmoi cat ~/.gitconfig

# すべての変更の差分を確認
chezmoi diff

# テンプレート変数の値を確認
chezmoi data
```

### 参考情報

- [chezmoi templating公式ドキュメント](https://www.chezmoi.io/user-guide/templating/)
- テンプレートシンタックス：Go の text/template
- 利用可能な変数：`.chezmoi.os`, `.chezmoi.osRelease`, `.chezmoi.arch`, etc.

## 初期セットアップ

### macOS / Linux環境

**初回設定時の流れ**: 新しいPCではHomebrewがインストールされていない状態から始まります。以下の手順で段階的に環境を構築します。

#### 1. chezmoiのインストール

```bash
# 公式のインストールスクリプトを使用
sh -c "$(curl -fsLS get.chezmoi.io)"
```

#### 2. リポジトリの初期化

```bash
chezmoi init https://github.com/yellow-seed/dotfiles.git

# chezmoiの設定ディレクトリに移動
chezmoi cd

# 設定をホームディレクトリに適用
chezmoi apply
```

#### 3. Homebrewのインストールとパッケージの一括インストール

```bash
# Homebrewをインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# BrewfileからHomebrewパッケージを一括インストール（miseも含む）
chezmoi cd
brew bundle install --file=dot_Brewfile
```

#### 4. miseのセットアップ

```bash
# miseでツールをインストール（chezmoiで管理された設定から）
mise install
```

**注意**: `.zshrc`にmiseの有効化設定が含まれているため、`chezmoi apply`実行後に新しいシェルセッションを開始すれば自動的にmiseが有効になります。

### Windows環境

Windows環境では、wingetを使用してパッケージを管理します。詳細な手順は [install/windows/README.md](install/windows/README.md) を参照してください。

#### chezmoiセットアップ

```powershell
# Windows PowerShell向け chezmoi セットアップ
.\install\windows\chezmoi.ps1
```

#### クイックスタート

```powershell
# 1. セットアップ（Winget確認・開発ツール・パッケージを順次実行）
.\install\windows\setup.ps1

# 2. Wingetの確認
.\install\windows\01-winget.ps1

# 3. 開発ツールのインストール（Pester, PSScriptAnalyzerなど）
.\install\windows\02-dev-tools.ps1

# 4. パッケージのインストール
.\install\windows\03-packages.ps1

# 5. テストの実行（開発者向け）
.\install\windows\run_unit_test.ps1
```

#### Windows環境の管理対象

- **Winget**: Windowsアプリケーション管理（Git, VS Code, PowerShell, GitHub CLIなど）
- **Pester**: PowerShellテストフレームワーク
- **PSScriptAnalyzer**: PowerShellスクリプトの静的解析

詳細は [install/windows/README.md](install/windows/README.md) を参照してください。

## 基本的な運用コマンド

### 初期設定・ディレクトリ移動

```bash
# chezmoiの設定ディレクトリに移動
chezmoi cd

# 現在のホームディレクトリの設定をchezmoiに追加
chezmoi add ~/.zshrc
chezmoi add ~/.gitconfig
chezmoi add ~/.config/mise/config.toml
```

### 設定の適用・確認

```bash
# 設定をホームディレクトリに適用
chezmoi apply

# 設定の差分を確認（実際には適用しない）
chezmoi diff

# 設定の状態を確認
chezmoi status
```

### 設定の編集

```bash
# 設定ファイルを編集（chezmoiディレクトリ内のファイルを直接編集）
chezmoi edit ~/.zshrc

# または、chezmoi cdでディレクトリに移動してから編集
chezmoi cd
vim dot_zshrc
```

### 設定の管理

```bash
# 設定ファイルを削除
chezmoi remove ~/.zshrc

# 設定ファイルを更新（ホームディレクトリの変更をchezmoiに反映）
chezmoi re-add ~/.zshrc

# 設定ファイルの情報を表示
chezmoi cat ~/.zshrc
```

## Homebrewパッケージ管理

Homebrewでパッケージをインストール・アンインストールした際は、`install/macos/02-brew-packages.sh` 内のパッケージ配列を更新してください。新しいマシンでのセットアップ時にこのスクリプトが自動実行されます。

### Brewfileダンプ（任意）

現在インストール済みのパッケージ一覧を `Brewfile` に記録したい場合は、ダンプスクリプトを使用できます。Brewfile はあくまで記録用であり、セットアップ時のインストールには `02-brew-packages.sh` が使用されます。

```bash
# 現在のHomebrewパッケージをBrewfileにダンプ
bash install/macos/brew-dump-explicit.sh install/macos/Brewfile
```

### 自動インストールスクリプトの使用

`install/macos/02-brew-packages.sh` を使用することで、パッケージインストールを自動化できます。

```bash
# パッケージを一括インストール
bash install/macos/02-brew-packages.sh
```

このスクリプトは以下の処理を行います：

- Homebrewがインストールされているか確認
- スクリプト内に定義されたtap/formulae/caskリストからパッケージをインストール

### パッケージの追加・削除方法

#### パッケージの追加

```bash
# Homebrewでパッケージをインストール
brew install <package-name>

# install/macos/02-brew-packages.sh 内の該当配列（formulae または casks）にパッケージを追加
# ※ 新しいマシンでのセットアップ時に自動インストールされるようにするため

# （任意）Brewfileをダンプして現在の状態を記録
bash install/macos/brew-dump-explicit.sh install/macos/Brewfile

# 変更をコミット
git add install/macos/02-brew-packages.sh install/macos/Brewfile
git commit -m "chore: <package-name>を追加"
git push origin main
```

#### パッケージの削除

```bash
# Homebrewでパッケージをアンインストール
brew uninstall <package-name>

# install/macos/02-brew-packages.sh 内の該当配列からパッケージを削除

# （任意）Brewfileをダンプして現在の状態を記録
bash install/macos/brew-dump-explicit.sh install/macos/Brewfile

# 変更をコミット
git add install/macos/02-brew-packages.sh install/macos/Brewfile
git commit -m "chore: <package-name>を削除"
git push origin main
```

### ローカルでのテスト方法

新しいパッケージを追加した際は、以下の手順でテストできます：

```bash
# ドライランモードで動作確認
DRY_RUN=true bash install/macos/02-brew-packages.sh

# 実際にインストールを実行
bash install/macos/02-brew-packages.sh
```

## mise設定管理

miseでツールのバージョンを追加・変更・削除した際は、以下の手順で設定ファイルを更新し、chezmoiで管理します。

### mise設定更新の手順

```bash
# miseの設定をchezmoiで管理対象に追加（初回のみ）
chezmoi add ~/.config/mise/config.toml

# miseでツールを追加・変更・削除
mise use --global node@20.0.0
mise use --global python@3.11
mise uninstall go@1.21

# 設定ファイルを更新（ホームディレクトリの変更をchezmoiに反映）
chezmoi re-add ~/.config/mise/config.toml

# 変更をコミット
git add .
git commit -m "chore: mise設定を更新"
git push origin main
```

### mise設定時の注意事項

- miseでツールのバージョンを変更した後は必ず上記の手順を実行する
- `chezmoi re-add`でホームディレクトリの変更をchezmoiに反映
- 新しいPCでの環境構築時は`mise install`で設定ファイルからツールを一括インストール可能
- miseの設定は`~/.config/mise/config.toml`に保存される

## ブランチ運用

### 基本的なブランチ運用方針

1. **既存のPC設定を単純に反映する場合**: 直接pushしても問題ありません
2. **新しい設定や機能追加**: ブランチを作成して作業することを推奨します

### ブランチ運用の手順

#### 新しい設定や機能追加の場合

```bash
# 新しいブランチを作成
git checkout -b feature/add-new-config

# 設定を追加・編集
chezmoi add ~/.newconfig
chezmoi edit ~/.newconfig

# 変更をコミット
git add .
git commit -m "feat: 新しい設定ファイルを追加"

# ブランチをプッシュ
git push origin feature/add-new-config

# プルリクエストを作成してマージ
```

#### 既存設定の修正・更新

```bash
# 修正用ブランチを作成
git checkout -b fix/update-config

# 設定を修正
chezmoi edit ~/.zshrc

# 変更をコミット
git add .
git commit -m "fix: zshrcの設定を更新"

# ブランチをプッシュしてプルリクエスト
git push origin fix/update-config
```

#### 緊急の設定反映（直接push）

```bash
# 既存のPC設定をそのまま反映する場合
chezmoi add ~/.existingconfig
git add .
git commit -m "chore: 既存設定を反映"
git push origin main
```

### よく使用するコマンドの組み合わせ

```bash
# 新しいPCでの初期設定
chezmoi apply

# 設定変更の一連の流れ
chezmoi edit ~/.zshrc
chezmoi diff
chezmoi apply
git add .
git commit -m "feat: zshrcの設定を更新"
git push origin main

# 設定の確認
chezmoi status
chezmoi cat ~/.zshrc
```

## ローカルテスト環境（Docker）

開発者向けに、Docker環境でテストやLintを実行できます。

### Ubuntu向けDocker環境

Ubuntu環境でBATSテスト、ShellCheck、shfmt、actionlintを実行できます。

#### 環境構築

```bash
# Dockerイメージをビルド
cd docker/ubuntu-test
docker compose build
```

#### テスト実行

```bash
# BATSテストを実行
cd docker/ubuntu-test
docker compose run ubuntu-test bats tests/

# 特定のテストファイルのみ実行
docker compose run ubuntu-test bats tests/example.bats
```

#### Lint実行

```bash
# ShellCheckによる静的解析
cd docker/ubuntu-test
docker compose run ubuntu-test lint-shell

# shfmtによるフォーマットチェック
docker compose run ubuntu-test shfmt -d -i 2 .

# shfmtで自動フォーマット
docker compose run ubuntu-test shfmt -i 2 -w .

# actionlintでGitHub Actionsワークフローを検証
docker compose run ubuntu-test actionlint
```

#### 環境の詳細

- **ベースイメージ**: Ubuntu 22.04
- **インストール済みツール**:
  - kcov（カバレッジ計測）
  - BATS（Bash Automated Testing System）
  - ShellCheck（シェルスクリプト静的解析）
  - shfmt（シェルスクリプトフォーマッター）
  - actionlint（GitHub Actionsワークフロー検証）

### macOS向けDocker環境

macOS環境でBATSテスト、ShellCheck、shfmt、actionlintを実行できます。

#### 環境構築

```bash
# Dockerイメージをビルド
cd docker/macos-test
docker compose build
```

#### テスト実行

```bash
# BATSテストを実行
cd docker/macos-test
docker compose run macos-test bats tests/

# 特定のテストファイルのみ実行
docker compose run macos-test bats tests/example.bats
```

#### Lint実行

```bash
# ShellCheckによる静的解析
cd docker/macos-test
docker compose run macos-test lint-shell

# shfmtによるフォーマットチェック
docker compose run macos-test shfmt -d -i 2 .

# shfmtで自動フォーマット
docker compose run macos-test shfmt -i 2 -w .

# actionlintでGitHub Actionsワークフローを検証
docker compose run macos-test actionlint
```

#### 環境の詳細

- **ベースイメージ**: Ubuntu 22.04
- **インストール済みツール**:
  - kcov（カバレッジ計測）
  - BATS（Bash Automated Testing System）
  - ShellCheck（シェルスクリプト静的解析）
  - shfmt（シェルスクリプトフォーマッター）
  - actionlint（GitHub Actionsワークフロー検証）

### Windows向けDocker環境

Windows PowerShell環境でPesterテストを実行できます。

```bash
# Dockerイメージをビルド
cd docker/windows-test
docker compose build

# PowerShellテストを実行
docker compose run --rm windows-test

# PowerShellシェルに入る
docker compose run --rm windows-test-shell
```

詳細は [install/windows/README.md](install/windows/README.md) を参照してください。

## その他規約

- 開発に関する規約は`AGENTS.md`に記載
- `chezmoi apply`を実行する前に`chezmoi diff`で変更内容を確認することを推奨
- 重要な設定変更は必ずブランチを作成して作業する
- コミットメッセージは[Conventional Commits](https://www.conventionalcommits.org/)の形式に従う
