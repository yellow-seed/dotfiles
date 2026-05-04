---
name: chezmoi-sync
description: "dotfiles追加・更新・適用スキル。chezmoi add/re-add/edit/diff/applyの一連操作とコミットを実行。Use when: dotfileを追加/更新したい、設定を反映したい、chezmoiで管理したい、chezmoi syncを依頼された時。"
---

# chezmoi-sync: dotfiles追加・更新・適用

chezmoiを使ったdotfilesの追加・編集・適用・コミットを一連の手順で実行します。

## 操作パターン

| ユーザーの意図 | 使用するコマンド |
|---|---|
| 新しい設定ファイルをchezmoiに追加したい | `chezmoi add` |
| ホームディレクトリの変更をchezmoiに反映したい | `chezmoi re-add` |
| chezmoiで管理中のファイルを編集したい | `chezmoi edit` |
| 変更内容を確認してから適用したい | `chezmoi diff` → `chezmoi apply` |
| 現在の状態を確認したい | `chezmoi status` / `chezmoi cat` |

## 実行手順

### 1. ブランチの判断と作成

| 変更の種類 | ブランチ方針 |
|---|---|
| 既存PC設定をそのまま反映（内容変更なし） | `main` に直接コミット可 |
| 設定内容の変更・新規ファイル追加 | ブランチを作成して作業する |

```bash
# 新しい設定や機能追加の場合はブランチを作成
git checkout -b chore/update-<対象ファイル名>
```

### 2. 対象ファイルと操作の確認

ユーザーのリクエストから以下を判断する：
- **操作種別**: 新規追加 / 更新 / 編集 / 適用のみ
- **対象ファイル**: `~/.zshrc`, `~/.gitconfig`, `~/.config/mise/config.toml` など

### 3. 現在の状態確認

```bash
# chezmoiが管理しているファイルの状態を確認
chezmoi status

# 適用前の差分を確認
chezmoi diff
```

### 4. 操作実行

#### 新規ファイルの追加

```bash
# ホームディレクトリのファイルをchezmoiに追加
chezmoi add ~/.config/newapp/config.yml
```

#### 既存ファイルの更新（ホームディレクトリ → chezmoi）

```bash
# ホームディレクトリの変更をchezmoiソースに反映
chezmoi re-add ~/.zshrc
```

#### ファイルの編集（chezmoi経由）

```bash
# chezmoiディレクトリ内のファイルを編集
chezmoi edit ~/.zshrc
```

#### 変更の適用（chezmoi → ホームディレクトリ）

```bash
# 差分確認（必須）
chezmoi diff

# 問題なければ適用
chezmoi apply
```

### 5. テンプレートファイルの確認（.tmpl ファイルの場合）

```bash
# テンプレートの展開結果を確認
chezmoi cat ~/.gitconfig

# テンプレート変数の確認
chezmoi data
```

### 6. コミット

変更内容を git-commit スキルに従ってコミットする。

```bash
# 変更ファイルを確認
git status
git diff

# ステージングとコミット
git add home/
git commit -m "$(cat <<'EOF'
chore: <対象ファイル>のdotfiles設定を更新

<変更内容の説明>

🤖 Generated with [Codex](https://Codex.com/Codex)

Co-Authored-By: Codex Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

## コミットメッセージの型

| 操作 | type | 例 |
|---|---|---|
| 新規ファイル追加 | `feat` | `feat: mise設定をchezmoiに追加` |
| 設定内容の変更 | `chore` | `chore: zshrcのエイリアスを更新` |
| 設定ファイルの修正 | `fix` | `fix: gitconfigのメールアドレスを修正` |

## 注意事項

- `chezmoi apply` の前に必ず `chezmoi diff` で差分を確認する
- テンプレートファイル（`.tmpl`）を変更した場合は `chezmoi cat` で展開結果を確認する
- PR を作成する場合、Chezmoi設定変更を含むときは `chezmoi apply --dry-run --verbose` の出力をPR本文に記載する（AGENTS.md の規約）
