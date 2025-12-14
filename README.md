# dotfiles

[![codecov](https://codecov.io/gh/yellow-seed/dotfiles/branch/main/graph/badge.svg)](https://codecov.io/gh/yellow-seed/dotfiles)

chezmoiを使用したdotfiles管理のガイドです。

## ディレクトリ構造

```
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
- **役割**: macOSアプリケーションのインストール・管理、Brewfileによる一括管理

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

**初回設定時の流れ**: 新しいPCではHomebrewがインストールされていない状態から始まります。以下の手順で段階的に環境を構築します。

### 1. chezmoiのインストール

```bash
# 公式のインストールスクリプトを使用
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 2. リポジトリの初期化

```bash
chezmoi init https://github.com/yellow-seed/dotfiles.git

# chezmoiの設定ディレクトリに移動
chezmoi cd

# 設定をホームディレクトリに適用
chezmoi apply
```

### 3. Homebrewのインストールとパッケージの一括インストール

```bash
# Homebrewをインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# BrewfileからHomebrewパッケージを一括インストール（miseも含む）
chezmoi cd
brew bundle install --file=dot_Brewfile
```

### 4. miseのセットアップ

```bash
# miseでツールをインストール（chezmoiで管理された設定から）
mise install
```

**注意**: `.zshrc`にmiseの有効化設定が含まれているため、`chezmoi apply`実行後に新しいシェルセッションを開始すれば自動的にmiseが有効になります。

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

## Homebrew Bundle管理

Homebrewでパッケージをインストール・アンインストールした際は、以下の一連の流れを実行してBrewfileを更新し、chezmoiで管理します。

### Homebrew Bundle更新の手順

```bash
# 現在のHomebrewパッケージをBrewfileに出力
brew bundle dump --describe --force --file=~/.Brewfile

# chezmoiで管理対象に追加（初回のみ）
chezmoi add ~/.Brewfile

# または、設定ファイルを更新（ホームディレクトリの変更をchezmoiに反映）
chezmoi re-add ~/.Brewfile

# 変更をコミット
git add .
git commit -m "chore: Brewfileを更新"
git push origin main
```

### 注意事項

- Homebrewでパッケージをインストール・アンインストールした後は必ず上記の手順を実行する
- `--describe`オプションでパッケージの説明も含めて出力
- `--force`オプションで既存のBrewfileを上書き
- 新しいPCでの環境構築時は`brew bundle install`でBrewfileからパッケージを一括インストール可能

### 自動インストールスクリプトの使用

`install/macos/common/brewfile.sh` を使用することで、Brewfileからのパッケージインストールを自動化できます。

```bash
# Brewfileからパッケージを一括インストール
bash install/macos/common/brewfile.sh
```

このスクリプトは以下の処理を行います：
- Homebrewがインストールされているか確認
- `install/macos/common/Brewfile` が存在するか確認
- `brew bundle` を実行してパッケージをインストール

### パッケージの追加・削除方法

#### パッケージの追加
```bash
# Homebrewでパッケージをインストール
brew install <package-name>

# Brewfileを更新
brew bundle dump --describe --force --file=install/macos/common/Brewfile

# 変更をコミット
git add install/macos/common/Brewfile
git commit -m "chore: <package-name>をBrewfileに追加"
git push origin main
```

#### パッケージの削除
```bash
# Homebrewでパッケージをアンインストール
brew uninstall <package-name>

# Brewfileを更新
brew bundle dump --describe --force --file=install/macos/common/Brewfile

# 変更をコミット
git add install/macos/common/Brewfile
git commit -m "chore: <package-name>をBrewfileから削除"
git push origin main
```

### ローカルでのテスト方法

新しいパッケージを追加した際は、以下の手順でテストできます：

```bash
# 1. Brewfileの構文チェック
brew bundle check --file=install/macos/common/Brewfile

# 2. インストールする内容を確認（実際にはインストールしない）
brew bundle list --file=install/macos/common/Brewfile

# 3. 実際にインストールを実行
brew bundle install --file=install/macos/common/Brewfile

# または自動インストールスクリプトを使用
bash install/macos/common/brewfile.sh
```

## mise設定管理

miseでツールのバージョンを追加・変更・削除した際は、以下の手順で設定ファイルを更新し、chezmoiで管理します。

### mise設定更新の手順

```bash
# miseの設定をchezmoiで管理対象に追加（初回のみ）
chezmoi add ~/.config/mise/config.toml

# miseでツールを追加・変更・削除
mise use node@20.0.0
mise use python@3.11
mise uninstall go@1.21

# 設定ファイルを更新（ホームディレクトリの変更をchezmoiに反映）
chezmoi re-add ~/.config/mise/config.toml

# 変更をコミット
git add .
git commit -m "chore: mise設定を更新"
git push origin main
```

### 注意事項

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

### ブランチ命名規則

- `feature/` - 新機能追加
- `fix/` - バグ修正・設定修正
- `chore/` - 既存設定の反映・メンテナンス
- `docs/` - ドキュメント更新

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

## 開発ガイド

### シェルスクリプトのLint・フォーマット

このリポジトリでは、シェルスクリプトの品質向上のために[ShellCheck](https://www.shellcheck.net/)と[shfmt](https://github.com/mvdan/sh)を使用しています。

#### ShellCheck（静的解析）

ShellCheckはシェルスクリプトの文法エラー、潜在的なバグ、非推奨な書き方を検出します。

**インストール:**
```bash
# macOS
brew install shellcheck

# Ubuntu
sudo apt-get install shellcheck

# VS Code拡張機能（オプション）
# Brewfileに以下を追加して `brew bundle install` を実行
# vscode "timonwong.shellcheck"
```

**ローカルでの実行:**
```bash
# 単一ファイルをチェック
shellcheck install/macos/common/brew.sh

# すべてのシェルスクリプトをチェック
shellcheck install/**/*.sh scripts/**/*.sh setup.sh

# 特定のディレクトリ配下をチェック
shellcheck install/macos/common/*.sh
```

**VS Code統合:**
- ShellCheck拡張機能（`timonwong.shellcheck`）を手動でインストール可能
- エディタ内でリアルタイムに警告を表示

**CI/CD統合:**
- `.github/workflows/shellcheck.yml`でPR時に自動チェック
- すべてのシェルスクリプトが対象

**設定ファイル:**
- `.shellcheckrc`でプロジェクト共通のルールを設定
- 現在の設定: SC1091（sourced filesのフォロー）を無効化

#### shfmt（フォーマッター）

shfmtはシェルスクリプトの自動フォーマットツールです。

**インストール:**
```bash
# mise経由（推奨）
mise use shfmt@latest

# または Homebrew
brew install shfmt
```

**使用方法:**
```bash
# フォーマットの確認（変更なし）
shfmt -d .

# 自動フォーマット（ファイルを上書き）
shfmt -w .

# 特定のファイルのみフォーマット
shfmt -w install/macos/common/brew.sh
```

### テストの実行

シェルスクリプトの動作を検証するため、[BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core)を使用しています。

**すべてのテストを実行:**
```bash
# macOSの場合
bash scripts/macos/run_unit_test.sh

# Ubuntuの場合
bash scripts/ubuntu/run_unit_test.sh
```

**特定のテストファイルのみ実行:**
```bash
# BATSコマンドで直接実行
bats tests/install/macos/common/brew.bats

# ShellCheckのテスト
bats tests/files/shellcheck.bats
```

### コーディング規約

シェルスクリプトを作成・修正する際は、以下の規約に従ってください：

1. **エラーハンドリング**: 必ず`set -Eeuo pipefail`を設定
2. **ShellCheck検証**: すべてのスクリプトはShellCheckをパス
3. **コメント**: 日本語でのコメント推奨
4. **変数命名**: 環境変数は`UPPER_CASE`、ローカル変数は`lower_case`
5. **テスト**: 新しいスクリプトには対応するBATSテストを作成

## 注意事項

- `chezmoi apply`を実行する前に`chezmoi diff`で変更内容を確認することを推奨
- 重要な設定変更は必ずブランチを作成して作業する
- コミットメッセージは[Conventional Commits](https://www.conventionalcommits.org/)の形式に従う