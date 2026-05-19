{
  pkgs,
  inputs,
  system,
  ...
}:
{
  home.packages = [
    inputs.agenix.packages.${system}.default
    pkgs.alcove
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.ollama
    pkgs.pi-coding-agent
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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      AddKeysToAgent = "yes";
      IdentityFile = "~/.ssh/id_ed25519";
      UseKeychain = "yes";
    };
  };

  home.file = {
    ".hushlogin".text = "";
  };
}
