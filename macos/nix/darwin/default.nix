{ config, lib, pkgs, ... }:
{
  # nix-darwin が要求する必須設定
  system.stateVersion = 5;

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
  environment.systemPackages = with pkgs; [
    git
  ];

  # touch ID for sudo はローカルユーザー体験改善のため有効化
  security.pam.services.sudo_local.touchIdAuth = true;
}
