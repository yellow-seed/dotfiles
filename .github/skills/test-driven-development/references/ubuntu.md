# Ubuntu Code Change Guide

Ubuntu はサブ環境です。現状の `install/ubuntu/` は最小実装寄りで、実運用よりも CI / Linux 互換性の確認が主目的です。

## 技術スタック

- Shell: Bash
- Test: BATS
- Package manager: apt を想定
- Lint: ShellCheck
- Format: shfmt
- Test environment: `docker/ubuntu-test/docker-compose.yml`

## 主な対象

- `setup.sh`
- `install/common/*.sh`
- `install/common/*.bats`
- `install/ubuntu/*.sh`
- `install/ubuntu/*.bats`
- `tests/files/*.bats`

## 実装方針

- Bash スクリプトは `set -Eeuo pipefail` を基本にする。
- Linux 固有処理は `install/ubuntu/` に閉じ込める。
- macOS / Homebrew 前提の処理を Ubuntu 側に持ち込まない。
- Ubuntu 実装は現状 stub であるため、機能追加時は小さく始め、テストで期待値を明確にする。
- OS 共通化できる処理だけ `install/common/` に移す。

## テスト配置

- Ubuntu 固有のテストは `install/ubuntu/` に置く。
- OS 共通の挙動は `install/common/` または `tests/files/` に置く。

## よく使う検証

ローカル:

```bash
bats install/ubuntu/ install/common/ tests/files/
```

Docker:

```bash
docker compose -f docker/ubuntu-test/docker-compose.yml run --rm ubuntu-test bats install/ubuntu/ install/common/ tests/files/
docker compose -f docker/ubuntu-test/docker-compose.yml run --rm ubuntu-test bash docker/ubuntu-test/lint-shell
```

必要に応じて shfmt:

```bash
shfmt -d -i 2 .
```

## 完了前チェック

- Ubuntu の現状が stub であることを踏まえ、過剰な実装にしないこと。
- Linux 対応を追加した場合は、`setup.sh` の Linux 分岐との整合を確認すること。
- macOS 側の主運用フローを壊していないこと。
