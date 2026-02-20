{
  description = "My nix configs.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
    }:
    let
      system = "aarch64-darwin";
      host = "work";
      user = "alex";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
      darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
        modules = [
          (
            { pkgs, ... }:
            {
              nix.settings.experimental-features = "nix-command flakes";
              system.configurationRevision = self.rev or self.dirtyRev or null;
              system.stateVersion = 6;
              nixpkgs.hostPlatform = system;
              networking.hostName = host;
              system.primaryUser = user;
              users.knownUsers = [ user ];
              users.users.${user} = {
                uid = 501;
                home = "/Users/${user}";
                shell = pkgs.fish;
              };
              nixpkgs.config.allowUnfree = true;
              programs.fish.enable = true;

              homebrew = {
                enable = true;

                casks = [
                  "logi-options+"
                ];

                masApps = {
                  "uBlock Origin Lite" = 6745342698;
                };

                onActivation = {
                  cleanup = "zap";
                };
              };
            }
          )
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = ./home.nix;
            home-manager.extraSpecialArgs = {
              user = user;
            };
          }
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = user;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };
              mutableTaps = false;
            };
          }
          (
            { config, ... }:
            {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            }
          )
        ];
      };
    };
}
