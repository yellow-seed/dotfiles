# GitHub Actions ワークフロー

このディレクトリには、リポジトリの継続的インテグレーション（CI）用のGitHub Actionsワークフローが含まれています。

## ワークフロー一覧

### test_bats.yml (Test)

**目的**: プッシュおよびプルリクエスト時に自動的にBatsテストを実行し、コードカバレッジを測定します。

**トリガー**:
- `main`ブランチへのプッシュ
- `main`ブランチへのプルリクエスト

**テスト環境**:
- Ubuntu (ubuntu-latest)
- macOS (macos-latest)

**実行内容**:
1. Batsテストフレームワークのインストール
2. プラットフォームごとのスクリプトを使用したテスト実行
   - macOS: `scripts/macos/run_unit_test.sh`（kcovでカバレッジ測定）
   - Ubuntu: `scripts/ubuntu/run_unit_test.sh`（カバレッジなしのテスト）
   - 共通処理: `scripts/run_unit_test_common.sh`
3. Codecovへのカバレッジレポートのアップロード

**必要な設定**:
- `CODECOV_TOKEN`: リポジトリのSecretsに設定が必要（Codecovアカウントから取得）

**注意事項**:
- kcovはUbuntu 24.04のデフォルトリポジトリで利用できないため、現在カバレッジ測定はmacOS環境でのみ実行されます（`scripts/macos/run_unit_test.sh`経由）
- Ubuntu環境では`scripts/ubuntu/run_unit_test.sh`が実行され、カバレッジ測定なしでテストのみが実行されます
- Codecovトークンが設定されていない場合、カバレッジアップロードステップは失敗しますが、テスト自体は成功します

### test_chezmoi_apply.yml

**目的**: chezmoiの適用をテストして、dotfilesが正しくインストールできることを確認します。

**トリガー**:
- プッシュ時

**テスト環境**:
- macOS (macos-latest)

**実行内容**:
1. chezmoiをインストール
2. dotfilesを初期化して適用

### snippet-install.yml (E2E Setup Test)

**目的**: 実際のユーザー体験と同じ環境でdotfilesのセットアップ過程を定期的に自動実行してテストします。外部依存関係の変更やOSアップデートによる影響を早期発見します。

**トリガー**:
- 定期実行: 毎週金曜日の午前0時（UTC）
- 手動実行: `workflow_dispatch`による手動トリガー

**テスト環境**:
- Ubuntu (ubuntu-latest)
- macOS (macos-latest)

**実行内容**:
1. リポジトリのルートにある`setup.sh`スクリプトを使用してdotfilesをセットアップ
2. chezmoiが正しくインストールされていることを確認
3. chezmoiのバージョンを表示

**注意事項**:
- このワークフローは実際のユーザーがセットアップする環境を再現します
- `setup.sh`スクリプトはchezmoiの公式インストーラーを使用します
- CI環境での制限（ネットワーク、権限など）を考慮しています

## カバレッジレポート

カバレッジレポートはCodecovにアップロードされます。レポートを確認するには：

1. [Codecov](https://codecov.io/)でアカウントを作成
2. リポジトリを連携
3. トークンを取得してリポジトリのSecretsに`CODECOV_TOKEN`として追加

## ローカルでのテスト実行

ローカルでテストを実行する場合：

```bash
# 通常のテスト実行
bats tests/install/
bats tests/files/

# macOSでのカバレッジ付きテスト実行
bash scripts/macos/run_unit_test.sh
```

## 参考資料

- [Bats-core Documentation](https://github.com/bats-core/bats-core)
- [kcov](https://github.com/SimonKagstrom/kcov)
- [Codecov GitHub Action](https://github.com/codecov/codecov-action)
