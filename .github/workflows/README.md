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
2. `scripts/run_unit_test.sh`を使用したカバレッジ付きテスト実行
   - `tests/install/` ディレクトリのテスト（kcovでカバレッジ測定）
   - `tests/files/` ディレクトリのテスト
3. Codecovへのカバレッジレポートのアップロード

**必要な設定**:
- `CODECOV_TOKEN`: リポジトリのSecretsに設定が必要（Codecovアカウントから取得）

**注意事項**:
- kcovはUbuntu 24.04のデフォルトリポジトリで利用できないため、現在カバレッジ測定はmacOS環境でのみ実行されます
- Ubuntu環境ではカバレッジ測定なしでテストのみが実行されます
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

# カバレッジ付きテスト実行
bash scripts/run_unit_test.sh
```

## 参考資料

- [Bats-core Documentation](https://github.com/bats-core/bats-core)
- [kcov](https://github.com/SimonKagstrom/kcov)
- [Codecov GitHub Action](https://github.com/codecov/codecov-action)
