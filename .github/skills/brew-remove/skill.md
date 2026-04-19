---
name: brew-remove
description: "Homebrewパッケージ削除スキル。brew uninstallと02-brew-packages.shの更新・コミットまでを実行。Use when: brewパッケージを削除したい、Homebrewからアンインストールしたい、brew removeを依頼された時。"
---

# brew-remove: Homebrewパッケージ削除

Homebrewパッケージを削除し、新しいマシンでインストールされないよう `install/macos/02-brew-packages.sh` を更新してコミットします。

## 実行手順

### 1. ブランチの作成

パッケージ削除は設定変更にあたるため、ブランチを作成して作業する。

```bash
git checkout -b chore/brew-remove-<package-name>
```

### 2. 削除対象の確認

```bash
# インストール済みか確認
brew list | grep <package-name>

# どの配列（formulae/casks）に属するか確認
grep -n '<package-name>' install/macos/02-brew-packages.sh
```

### 3. Homebrew からアンインストール

```bash
brew uninstall <package-name>
# または GUI アプリの場合
brew uninstall --cask <package-name>
```

### 4. `install/macos/02-brew-packages.sh` を更新

`install/macos/02-brew-packages.sh` 内の該当する配列からパッケージ名を削除する。

削除後、配列内のアルファベット順が崩れていないか確認する。

### 5. （任意）Brewfile をダンプして記録を更新

```bash
bash install/macos/brew-dump-explicit.sh install/macos/Brewfile
```

### 6. ドライランで動作確認

```bash
DRY_RUN=true bash install/macos/02-brew-packages.sh
```

### 7. コミット

```bash
# 変更ファイルを確認
git diff install/macos/02-brew-packages.sh

# ステージングとコミット
git add install/macos/02-brew-packages.sh install/macos/Brewfile
git commit -m "$(cat <<'EOF'
chore: <package-name>をHomebrewパッケージから削除

不要になったパッケージを02-brew-packages.shから削除。

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

## 注意事項

- 削除前に他のパッケージが依存していないか確認する（`brew uses --installed <package-name>`）
- tap を追加したパッケージを削除する場合、`taps` 配列からの削除も検討する（他に使用中のパッケージがなければ削除）
- Brewfile はあくまで記録用。セットアップ時の実体は `02-brew-packages.sh`
