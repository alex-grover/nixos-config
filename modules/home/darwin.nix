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
    pkgs.herdr
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

  programs.pi-coding-agent = {
    enable = true;
    extraPackages = [ pkgs.nodejs ];
    settings = {
      lastChangelogVersion = pkgs.pi-coding-agent.version;
      defaultProvider = "openai-codex";
      defaultModel = "gpt-5.6-sol";
      defaultThinkingLevel = "high";
      packages = [
        "npm:pi-web-access@0.18.0"
        "npm:@plannotator/pi-extension@0.26.1"
      ];
      theme = "dark";
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

  home.file.".hushlogin".text = "";
}
