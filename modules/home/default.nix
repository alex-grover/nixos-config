{
  pkgs,
  user,
  configPath,
  ...
}:
{
  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
  home.username = user;

  home.packages = [
    pkgs.fd
    pkgs.jj-starship
    pkgs.postgresql
    pkgs.ripgrep
  ];

  home.sessionVariables = {
    ADBLOCK = "1";
    DISABLE_OPENCOLLECTIVE = "true";
  };

  programs.bat.enable = true;

  programs.bun.enable = true;

  programs.delta = {
    enable = true;
    enableJujutsuIntegration = true;
    options.navigate = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;

    interactiveShellInit = "set fish_greeting";

    functions = {
      cat = {
        wraps = "bat";
        body = "bat $argv";
      };
      grep = {
        wraps = "rg";
        body = "rg $argv";
      };
    };

    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.gh.enable = true;

  programs.git.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "ayu_dark";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Alex Grover";
        email = "hello@alexgrover.me";
      };

      signing = {
        behavior = "own";
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };

      git.colocate = false;

      templates = {
        git_push_bookmark = "\"alex/\" ++ change_id.short()";
      };

      revsets = {
        bookmark-advance-to = "closest_pushable(@)";
      };

      revset-aliases = {
        "closest_pushable(to)" =
          "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
      };

      ui = {
        default-command = "status";
        diff-editor = ":builtin";
        merge-editor = ":builtin";
      };
    };
  };

  programs.nh = {
    enable = true;
    flake = configPath;
    clean.enable = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      custom.jj = {
        when = "jj-starship detect";
        shell = [ "jj-starship" ];
        format = "$output ";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };
}
