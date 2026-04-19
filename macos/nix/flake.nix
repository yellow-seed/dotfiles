{
  description = "dotfiles - nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      ...
    }:
    let
      defaultHost = "dotfiles";
      intelHost = "dotfiles-intel";
      mkDarwinSystem = hostName: system:
        nix-darwin.lib.darwinSystem {
          modules = [
            ./darwin/default.nix
            {
              networking.hostName = hostName;
              nixpkgs.hostPlatform = system;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        "${defaultHost}" = mkDarwinSystem defaultHost "aarch64-darwin";
        "${intelHost}" = mkDarwinSystem intelHost "x86_64-darwin";
      };

      checks = {
        darwin-aarch64 = self.darwinConfigurations."${defaultHost}".system;
        darwin-x86_64 = self.darwinConfigurations."${intelHost}".system;
      };
    };
}
