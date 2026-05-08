## なぜやるか

template同期（22bfb203）で削除された `ci-windows.yml` `ci-ubuntu.yml` を復活させる。当時はパスフィルタがなく全push/PRで実行されていたため、各OS固有の `install/` ディレクトリに変更があった場合のみトリガーするよう改善する。`install/common/**` は別途 `ci-common.yml` で検証する。NixLint は `ci-macos.yml` から `ci.yml` に集約し、低コストな ubuntu-latest runner で実行する。

## Ref

- 削除コミット: [22bfb203](https://github.com/yellow-seed/dotfiles/commit/22bfb203) - chore: template同期を反映
- 既存 `ci-macos.yml`: `.github/workflows/ci-macos.yml`（パスフィルタ実装例）
- template-sync スキル: `.agents/skills/template-sync/SKILL.md`
