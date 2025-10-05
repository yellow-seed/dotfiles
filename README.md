# dotfiles

chezmoiを使用したdotfiles管理のガイドです。

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

## 注意事項

- `chezmoi apply`を実行する前に`chezmoi diff`で変更内容を確認することを推奨
- 重要な設定変更は必ずブランチを作成して作業する
- コミットメッセージは[Conventional Commits](https://www.conventionalcommits.org/)の形式に従う