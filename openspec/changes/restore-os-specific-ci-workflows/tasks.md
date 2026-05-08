## 1. ci-common.yml の新規作成

- [x] 1.1 `ci-common.yml` を `install/common/**` のパスフィルタ付きで作成する
- [x] 1.2 BATS ジョブを構成する（ShellCheck + shfmt は qlty でカバーするため省略）

## 2. ci-windows.yml の復活

- [x] 2.1 `ci-windows.yml` を `install/windows/**` のパスフィルタ付きで作成する
- [x] 2.2 Pester テストジョブ + PSScriptAnalyzer ジョブを構成する

## 3. ci-ubuntu.yml の復活

- [x] 3.1 `ci-ubuntu.yml` を `install/ubuntu/**` のパスフィルタ付きで作成する
- [x] 3.2 BATS ジョブを構成する（ShellCheck + shfmt は qlty でカバー可能なため省略）

## 4. NixLint の配置変更

- [x] 4.1 `ci.yml` に NixLint ジョブを維持（ubuntu-latest の方が macOS runner より低コストなため）
- [x] 4.2 `ci-macos.yml` から Nix Flake Check 以外の不要な処理を削除する（既に Flake Check のみ）

## 5. 検証

- [x] 5.1 全 workflow ファイルの YAML 構文を検証する
- [x] 5.2 `ci.yml` で qlty lint + bats test + NixLint が正常に動作することを確認する
