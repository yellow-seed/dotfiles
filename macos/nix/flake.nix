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
      baseHost = "dotfiles";
      defaultHost = baseHost;
      intelHost = "${baseHost}-intel";
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
        aarch64-darwin.default = self.darwinConfigurations."${defaultHost}".system;
        x86_64-darwin.default = self.darwinConfigurations."${intelHost}".system;
      };
    };
}
