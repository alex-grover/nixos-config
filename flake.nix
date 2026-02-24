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
      hosts = [
        "personal"
        "work"
      ];
      user = "alex";

      mkHost =
        host:
        nix-darwin.lib.darwinSystem {
          modules = [
            (
              { pkgs, ... }:
              import ./modules/darwin.nix {
                inherit
                  self
                  pkgs
                  user
                  host
                  system
                  ;
              }
            )
            ./hosts/${host}.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} =
                { ... }:
                {
                  imports = [
                    ./modules/home
                    ./modules/home/${host}.nix
                  ];
                };
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
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
      darwinConfigurations = nixpkgs.lib.genAttrs hosts mkHost;
    };
}
