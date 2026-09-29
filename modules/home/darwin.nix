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
    pkgs.spotify
    pkgs.tinycast
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
    package = pkgs.callPackage ../../pkgs/pi-coding-agent { };
    extraPackages = [ pkgs.nodejs ];
    settings = {
      defaultProvider = "vercel-ai-gateway";
      defaultModel = "openai/gpt-6.1-sol";
      defaultThinkingLevel = "high";
      packages = [
        "npm:pi-web-access@0.33.0"
        "npm:@plannotator/pi-extension@0.27.22"
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

  home.file = {
    ".agents/skills" = {
      source = ../../skills;
      recursive = true;
    };
    ".hushlogin".text = "";
  };
}
