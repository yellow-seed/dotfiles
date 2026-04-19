---
name: brew-add
description: "Homebrewパッケージ追加スキル。brew installと02-brew-packages.shの更新・コミットまでを実行。Use when: brewパッケージを追加したい、Homebrewにインストールしたい、brew addを依頼された時。"
---

# brew-add: Homebrewパッケージ追加

Homebrewパッケージを追加し、新しいマシンでも自動インストールされるよう `install/macos/02-brew-packages.sh` を更新してコミットします。

## 実行手順

### 1. ブランチの作成

パッケージ追加は設定変更にあたるため、ブランチを作成して作業する。

```bash
git checkout -b chore/brew-add-<package-name>
```

### 2. パッケージ種別の確認

追加対象が何の配列に属するか判断する：

| 種別 | 配列変数名 | 例 |
|---|---|---|
| tap | `taps` | `homebrew/cask-fonts` |
| CLI ツール | `formulae` | `ripgrep`, `jq`, `gh` |
| GUI アプリ | `casks` | `visual-studio-code`, `1password` |

```bash
# パッケージ情報を確認
brew info <package-name>
```

### 3. Homebrew でインストール

```bash
brew install <package-name>
# または GUI アプリの場合
brew install --cask <package-name>
```

### 4. `install/macos/02-brew-packages.sh` を更新

`install/macos/02-brew-packages.sh` 内の該当する配列にパッケージ名をアルファベット順で追加する。

```bash
# 現在の配列内容を確認
grep -A 30 'formulae=(' install/macos/02-brew-packages.sh
# または
grep -A 30 'casks=(' install/macos/02-brew-packages.sh
```

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
chore: <package-name>をHomebrewパッケージに追加

新しいマシンでも自動インストールされるよう02-brew-packages.shに追加。

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

## 注意事項

- `02-brew-packages.sh` の配列内はアルファベット順を維持する
- GUI アプリ（cask）は `formulae` ではなく `casks` 配列に追加する
- tap が必要なパッケージは `taps` 配列にも追加する
- Brewfile はあくまで記録用。セットアップ時の実体は `02-brew-packages.sh`
