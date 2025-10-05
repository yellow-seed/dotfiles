# dotfiles

chezmoiを使用したdotfiles管理のガイドです。

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