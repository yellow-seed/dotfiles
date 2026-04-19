# macOS Code Change Guide

macOS はこの dotfiles の主運用環境です。macOS 向けの変更では、実用性とテスト品質を優先してください。

## 技術スタック

- Shell: Bash
- Test: BATS
- Package manager: Homebrew
- Lint: ShellCheck
- Format: shfmt
- Test environment: `docker/macos-test/docker-compose.yml`

## 主な対象

- `setup.sh`
- `install/common/*.sh`
- `install/common/*.bats`
- `install/macos/*.sh`
- `install/macos/*.bats`
- `install/macos/Brewfile`
- `install/macos/{work,private}/Brewfile`
- `tests/files/*.bats`

## 実装方針

- Bash スクリプトは `set -Eeuo pipefail` を基本にする。
- Homebrew 関連の処理は `install/macos/` に閉じ込める。
- パッケージ追加・削除の手続きは、該当する Homebrew 系 Skill を優先する。
- 実インストールを伴う処理は、dry-run やコマンド差し替えでテストできる構造にする。
- macOS 固有処理を `install/common/` に置かない。

## テスト配置

- 実装ファイルと同じ `install/macos/` に BATS テストを置く。
- OS 共通の挙動は `install/common/` または `tests/files/` に置く。
- ファイル構造やテンプレート検証は `tests/files/` を使う。

## よく使う検証

ローカル:

```bash
bats install/macos/ install/common/ tests/files/
```

Docker:

```bash
docker compose -f docker/macos-test/docker-compose.yml run --rm macos-test bats install/macos/ install/common/ tests/files/
docker compose -f docker/macos-test/docker-compose.yml run --rm macos-test bash docker/macos-test/lint-shell
```

必要に応じて shfmt:

```bash
shfmt -d -i 2 .
```

## 完了前チェック

- macOS の既存テストが通ること。
- ShellCheck / shfmt の対象になる変更では lint / format を確認すること。
- Homebrew パッケージ管理を変更した場合は、関連 Skill の手順と矛盾しないこと。
