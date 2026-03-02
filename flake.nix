{
  description = "My nix configs.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
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
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
    }:
    let
      user = "alex";

      platforms = {
        darwin = {
          aarch64-darwin = [
            "personal"
            "work"
          ];
        };

        nixos = {
          x86_64-linux = [ "nas" ];
        };
      };

      mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs user; };
      mkConfigurations = nixpkgs.lib.concatMapAttrs (
        system: hosts: nixpkgs.lib.genAttrs hosts (name: mkSystem { inherit name system; })
      );
    in
    {
      formatter = nixpkgs.lib.genAttrs (builtins.concatMap builtins.attrNames (
        builtins.attrValues platforms
      )) (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      darwinConfigurations = mkConfigurations platforms.darwin;
      nixosConfigurations = mkConfigurations platforms.nixos;
    };
}
