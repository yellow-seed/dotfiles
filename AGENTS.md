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

```
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

## 開発とテスト方法

### ローカルテスト実行

#### macOSでテスト実行:
```bash
bash scripts/macos/run_unit_test.sh
```

#### Ubuntuでテスト実行:
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

### CI/CDワークフロー

1. **test_bats.yml**: macOSとUbuntuでBATSテストを実行
2. **test_chezmoi_apply.yml**: chezmoiの適用が正常に動作するか検証
3. **copilot-setup-steps.yml**: GitHub Copilot用の検証環境構築

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
brew bundle dump --describe --force --file=~/dotfiles/home/dot_Brewfile

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

4. **テスト必須事項**:
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
