{ pkgs, ... }:
{
  home.packages = [
    pkgs.alcove
    pkgs.jetbrains.webstorm
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.raycast
    pkgs.spotify
  ];

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    package = pkgs.ghostty-bin;
    settings = {
      theme = "Ayu";
    };
  };

  programs.git.settings.credential.helper = "osxkeychain";

  home.file = {
    ".hushlogin".text = "";
  };
}
