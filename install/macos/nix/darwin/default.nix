{ config, lib, ... }:
{
  # nix-darwin が要求する必須設定
  system.stateVersion = 5;

  # ユーザー設定オプション（dock, CustomUserPreferences 等）を使うために必要
  system.primaryUser = "kazuya";

  # Determinate Systems の Nix を利用する場合は false を維持
  nix.enable = false;

  # nix-darwin で Nix を管理する場合のみ nix.conf 設定を反映
  nix.settings = lib.mkIf config.nix.enable {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # 既存の chezmoi / Homebrew / mise を維持しながら段階導入
  environment.systemPackages = [ ];

  # touch ID for sudo はローカルユーザー体験改善のため有効化
  security.pam.services.sudo_local.touchIdAuth = true;

  # 起動音を無効化
  system.startup.chime = false;

  # Dock は通常隠し、画面端に近づいた時だけ表示
  system.defaults.dock.autohide = true;

  # Finder は Dock の固定要素のため、明示管理するアプリだけ残す
  system.defaults.dock.persistent-apps = [
    { app = "/System/Applications/Launchpad.app"; }
    { app = "/System/Applications/App Store.app"; }
    { app = "/System/Applications/System Settings.app"; }
  ];

  # 最近使ったアプリ欄は表示
  system.defaults.dock.show-recents = true;

  # 日本語入力は自動変換せず、Space で明示的に変換する
  system.defaults.CustomUserPreferences = {
    "com.apple.inputmethod.Kotoeri" = {
      JIMPrefLiveConversionKey = false;
      JIMPrefPredictiveCandidateKey = false;
      JIMPrefConvertWithPunctuationKey = false;
    };
  };
}
