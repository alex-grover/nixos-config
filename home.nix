{ pkgs, user, ... }:
{
  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
  home.username = user;

  programs.nh = {
    enable = true;
    flake = "/etc/nix-darwin";
    clean.enable = true;
  };
}
