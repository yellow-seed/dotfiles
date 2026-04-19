# AGENTS.md - Agent Guide

## このリポジトリの本質

このリポジトリは、単なる dotfiles 集ではなく、`chezmoi` を中心にした **3OS対応の開発環境セットアップシステム** です。

AI エージェントは、個別の手順をその場で組み立てるよりも、次の設計思想に従って既存の入口・テスト・Skill を使って作業してください。

1. **OS差分は setup に寄せる**
   - macOS / Ubuntu / Windows を主要対象とする
   - OSごとの分岐は setup スクリプト側の責務とする
   - ユーザーや AI は、原則として上位の setup 入口を呼び出す

2. **検証環境は OS 別 compose から選ぶ**
   - macOS / Ubuntu / Windows 相当のテスト環境を `docker/*-test/docker-compose.yml` で管理する
   - 変更内容に応じて、必要な compose だけを起動する
   - 複数OSに影響する変更では、該当する compose を組み合わせて検証する

3. **手続き的な運用は Skill に委譲する**
   - パッケージの追加・削除、chezmoi 同期、コミット、PR 作成などは Skill 化された手順を優先する
   - AGENTS.md には詳細手順を詰め込まず、「何をしたいときに何を使うか」を書く

## 基本原則

- `home/` 配下は chezmoi のソースです。実ホームディレクトリを直接編集するのではなく、chezmoi 管理下のファイルを更新します。
- OS別インストール処理は `install/<os>/` に閉じ込めます。共通処理は `install/common/` に置きます。
- スクリプト変更では、実装と同じ階層にテストを置きます。
- macOS が主運用環境です。迷った場合、macOS の実用性とテスト品質を優先します。
- Ubuntu はサブ環境、Windows は PowerShell / winget ベースの別系統として扱います。
- 手順の詳細を AGENTS.md に増やしすぎず、README または Skill に逃がします。

## OS別セットアップ方針

### 共通入口

Unix 系環境では、ルートの `setup.sh` を入口にします。

```bash
sh setup.sh
```

`setup.sh` は `uname` によって OS を判定し、現状では次を呼び出します。

| OS | 呼び出し先 |
| --- | --- |
| macOS | `install/macos/setup.sh` |
| Linux | `install/ubuntu/setup.sh` |

Windows は PowerShell 系の入口を使います。

```powershell
.\install\windows\setup.ps1
```

### エージェントの判断

- OSごとの個別手順を勝手に増やす前に、既存の setup 入口に組み込めるかを確認します。
- OS判定ロジックを変更する場合は、`setup.sh` と該当 OS の setup テストを確認します。
- Windows 対応を触る場合は、Bash 側と混同せず PowerShell / Pester の流儀に合わせます。

## Compose 環境の使い分け

このリポジトリの compose は、OS別のテスト・検証環境として扱います。変更対象に応じて必要なものだけ使います。

| 目的 | compose |
| --- | --- |
| macOS 系 Bash / Homebrew スクリプトの検証 | `docker/macos-test/docker-compose.yml` |
| Ubuntu / Linux 系 Bash スクリプトの検証 | `docker/ubuntu-test/docker-compose.yml` |
| Windows PowerShell / Pester の検証 | `docker/windows-test/docker-compose.yml` |

例:

```bash
docker compose -f docker/macos-test/docker-compose.yml run --rm macos-test bats install/macos/ install/common/ tests/files/
docker compose -f docker/ubuntu-test/docker-compose.yml run --rm ubuntu-test bats install/ubuntu/ install/common/ tests/files/
docker compose -f docker/windows-test/docker-compose.yml run --rm windows-test
```

macOS / Ubuntu の compose には `lint-shell` もあります。シェルスクリプトや GitHub Actions を触った場合は、必要に応じて lint も実行します。

```bash
docker compose -f docker/macos-test/docker-compose.yml run --rm macos-test bash docker/macos-test/lint-shell
docker compose -f docker/ubuntu-test/docker-compose.yml run --rm ubuntu-test bash docker/ubuntu-test/lint-shell
```

## Skill への委譲方針

インストール、アンインストール、chezmoi 同期、コミット、PR 作成などの手続き的な作業は、AGENTS.md に手順を再掲しません。

該当する Skill がある作業では、まずその Skill を読み、そこに書かれた手順を優先します。Skill がない場合だけ、既存の README、スクリプト、テストから最小限の手順を判断します。

コード変更では、`test-driven-development` Skill を入口にします。対象 OS ごとの技術スタックや検証手順は、その Skill の OS 別 reference を必要なものだけ読みます。

## 変更時の判断ルール

### chezmoi 管理ファイル

- `home/` 配下を更新します。
- `.tmpl` を触る場合は、テンプレート展開結果を確認します。
- PR では `chezmoi apply --dry-run --verbose`、`chezmoi diff`、または `chezmoi execute-template` の結果を示します。

### パッケージ管理

- macOS のパッケージ追加・削除は `brew-add` / `brew-remove` Skill を優先します。
- macOS の基本パッケージは `install/macos/02-brew-packages.sh` と関連テストを確認します。
- プロファイル別パッケージは `install/macos/03-profile.sh` と `install/macos/{work,private}/Brewfile` の責務を確認します。
- Windows パッケージは `install/windows/packages.json` と `03-packages.ps1` 系を確認します。

### setup スクリプト

- `set -Eeuo pipefail` を基本とします。
- 失敗時のメッセージは、ユーザーが次に取る行動を判断できる内容にします。
- 実システムを変更する処理には、可能な範囲で dry-run やテストしやすい分岐を用意します。

### テスト

- macOS / Ubuntu のシェルテストは BATS を使います。
- Windows の PowerShell テストは Pester を使います。
- スクリプト変更では、実装ファイルと同じ OS ディレクトリに対応テストを置きます。
- ファイル構造やテンプレートの検証は `tests/files/` に置きます。

## よく使う検証コマンド

macOS 系:

```bash
bats install/macos/ install/common/ tests/files/
docker compose -f docker/macos-test/docker-compose.yml run --rm macos-test bats install/macos/ install/common/ tests/files/
```

Ubuntu 系:

```bash
bats install/ubuntu/ install/common/ tests/files/
docker compose -f docker/ubuntu-test/docker-compose.yml run --rm ubuntu-test bats install/ubuntu/ install/common/ tests/files/
```

Windows 系:

```powershell
.\install\windows\run_unit_test.ps1
```

```bash
docker compose -f docker/windows-test/docker-compose.yml run --rm windows-test
```

chezmoi:

```bash
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi execute-template < path/to/template.tmpl
```

## PR・レビュー時の注意

- 変更の影響範囲を OS 別に書きます。
- 実行したテストと、未実行の理由を明記します。
- chezmoi 設定変更を含む場合は、実際に適用される差分が分かるコマンド結果を示します。
- 手続き的な変更は、対応する Skill を使ったことが分かるようにします。

## 参照先

- ユーザー向けの詳細説明: `README.md`
- AI向け定型手順: `.github/skills/`
