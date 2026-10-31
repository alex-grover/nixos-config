{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.spotify
    pkgs.tinycast
  ];

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
      ];
      theme = "dark";
      tuiMode = "regular";
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
