# Windows Installation Scripts

Windows環境でのdotfilesセットアップ用スクリプト集です。

## 前提条件

- Windows 10/11
- PowerShell 5.1以降（PowerShell 7推奨）
- 管理者権限（一部のパッケージインストールに必要）

## クイックスタート

開発者向けのクイックセットアップ：

```powershell
# 1. 開発ツールをインストール（Pester, PSScriptAnalyzerなど）
.\install\windows\common\dev-tools.ps1

# 2. テストを実行
.\scripts\windows\run_unit_test.ps1

# 3. パッケージをインストール
.\install\windows\common\packages.ps1
```

## 使い方

### 0. 開発環境のセットアップ（開発者向け）

dotfilesの開発やテストを行う場合は、まず開発ツールをインストールしてください：

```powershell
.\install\windows\common\dev-tools.ps1
```

このスクリプトは以下をインストールします：

- **Pester 5.x**: PowerShellテストフレームワーク
- **PSScriptAnalyzer**: PowerShellスクリプトの静的解析ツール
- PowerShell 7+の推奨（インストール手順を表示）
- Git設定の最適化

### 1. Wingetのインストール確認

```powershell
# Wingetが利用可能か確認
.\install\windows\common\winget.ps1
```

Wingetがインストールされていない場合は、Microsoft Storeから「アプリ インストーラー」をインストールしてください。

### 2. パッケージのインストール

```powershell
# packages.jsonからパッケージをインストール
.\install\windows\common\packages.ps1

# 特定のファイルを指定してインストール
.\install\windows\common\packages.ps1 -File "C:\path\to\packages.json"
```

### 3. 現在のパッケージをエクスポート

```powershell
# デフォルト位置（~/.winget.json）にエクスポート
.\install\windows\common\packages.ps1 -Action export

# 特定のファイルにエクスポート
.\install\windows\common\packages.ps1 -Action export -File ".\my-packages.json"
```

## パッケージファイルの検索順序

`packages.ps1`は以下の順序でパッケージファイルを検索します：

1. `$env:USERPROFILE\.winget.json`（ホームディレクトリの.winget.json）
2. `$env:USERPROFILE\winget.json`（ホームディレクトリのwinget.json）
3. `install\windows\common\packages.json`（スクリプトと同じディレクトリ）
4. `install\windows\common\winget.json`

## パッケージリストのカスタマイズ

`packages.json`を編集して、インストールするパッケージを追加・削除できます：

```json
{
  "$schema": "https://aka.ms/winget-packages.schema.2.0.json",
  "Sources": [
    {
      "Packages": [
        {
          "PackageIdentifier": "Git.Git"
        },
        {
          "PackageIdentifier": "Microsoft.VisualStudioCode"
        }
      ],
      "SourceDetails": {
        "Name": "winget"
      }
    }
  ]
}
```

パッケージIDは以下のコマンドで検索できます：

```powershell
winget search <パッケージ名>
```

## トラブルシューティング

### Wingetが見つからない

Microsoft Storeから「アプリ インストーラー」をインストールしてください：
<https://www.microsoft.com/p/app-installer/9nblggh4nns1>

または、管理者権限のPowerShellで：

```powershell
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

### パッケージのインストールに失敗する

1. 管理者権限でPowerShellを実行してください
2. 実行ポリシーを確認してください：

```powershell
# 現在のポリシーを確認
Get-ExecutionPolicy

# 必要に応じて変更（管理者権限が必要）
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### デバッグモード

問題が発生した場合、デバッグモードで実行できます：

```powershell
$env:DOTFILES_DEBUG = "1"
.\install\windows\common\packages.ps1
```

## 参考リンク

- [Winget公式ドキュメント](https://learn.microsoft.com/ja-jp/windows/package-manager/winget/)
- [Wingetパッケージリポジトリ](https://github.com/microsoft/winget-pkgs)
