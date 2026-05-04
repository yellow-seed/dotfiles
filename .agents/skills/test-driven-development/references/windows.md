# Windows Code Change Guide

Windows は PowerShell / winget / Pester を中心にした別系統として扱います。Bash 側の慣習をそのまま持ち込まないでください。

## 技術スタック

- Shell: PowerShell
- Test: Pester
- Package manager: winget
- Package definition: `install/windows/packages.json`
- Test environment: `docker/windows-test/docker-compose.yml`

## 主な対象

- `install/windows/*.ps1`
- `install/windows/*.Tests.ps1`
- `install/windows/packages.json`
- `install/windows/run_unit_test.ps1`
- `install/windows/README.md`

## 実装方針

- `$ErrorActionPreference = "Stop"` と `Set-StrictMode -Version Latest` を基本にする。
- Windows 固有処理は `install/windows/` に閉じ込める。
- winget パッケージ管理は `packages.json` と `03-packages.ps1` 系の責務を確認する。
- 管理者権限や実インストールが必要な処理は、テストで直接実行しない構造にする。
- Bash / BATS の前提を Windows テストに持ち込まない。

## テスト配置

- 実装ファイルに対応する `.Tests.ps1` を `install/windows/` に置く。
- Windows 全体のテスト実行は `run_unit_test.ps1` に寄せる。

## よく使う検証

PowerShell:

```powershell
.\install\windows\run_unit_test.ps1
```

特定テスト:

```powershell
Invoke-Pester -Path install/windows/01-winget.Tests.ps1
```

Docker:

```bash
docker compose -f docker/windows-test/docker-compose.yml run --rm windows-test
```

## 完了前チェック

- Pester テストが通ること。
- winget パッケージ定義を変更した場合は JSON の構造と既存スクリプトの読み込み順を確認すること。
- Windows 変更を理由なく Bash 側へ波及させないこと。
