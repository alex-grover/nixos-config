{
  nixpkgs,
  inputs,
  user,
}:

{
  name,
  system,
}:

let
  isDarwin = nixpkgs.lib.hasSuffix "darwin" system;
  platform = if isDarwin then "darwin" else "nixos";
  configPath = if isDarwin then /etc/nix-darwin else /etc/nixos;

  systemFunc = if isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;

  homeManagerModule =
    if isDarwin then
      inputs.home-manager.darwinModules.home-manager
    else
      inputs.home-manager.nixosModules.home-manager;
in
systemFunc {
  specialArgs = {
    inherit
      inputs
      name
      user
      configPath
      ;
  };

  modules = [
    {
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.hostPlatform = system;
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      networking.hostName = name;
      programs.fish.enable = true;
    }
    ../modules/${platform}.nix
    ../hosts/${name}
    homeManagerModule
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {
        imports = [
          ../modules/home
          ../modules/home/${platform}.nix
          ../modules/home/${name}.nix
        ];
      };
      home-manager.extraSpecialArgs = {
        inherit
          inputs
          system
          user
          configPath
          ;
      };
    }
  ];
}
