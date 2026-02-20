{ pkgs, user, ... }:
{
  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
  home.username = user;

  home.packages = [
    pkgs.fd
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.ripgrep
  ];

  home.sessionVariables = {
    ADBLOCK = "1";
    DISABLE_OPENCOLLECTIVE = "true";
  };

  programs.bat.enable = true;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
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

    shellAbbrs = {
      ga = "git add";
      gb = "git branch";
      gc = "git commit";
      gd = "git diff";
      gdc = "git diff --cached";
      gf = "git fetch";
      gl = "git pull";
      glg = "git log --stat --graph";
      gls = "git ls-files";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gr = "git remote -v";
      gs = "git status";
      gt = "git checkout";
      gtb = "git checkout -b";
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

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Alex Grover";
        email = "hello@alexgrover.me";
      };

      github.user = "alex-grover";

      advice = {
        addEmptyPathspec = false;
        skippedCherryPicks = false;
      };

      branch = {
        autoSetupRebase = "always";
        sort = "-committerdate";
      };

      color.ui = "auto";

      column.ui = "auto";

      commit = {
        gpgsign = true;
        verbose = true;
      };

      credential.helper = "osxkeychain";

      diff = {
        colorMoved = "plain";
        algorithm = "histogram";
        renames = true;
        mnemonicPrefix = true;
      };

      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };

      gpg.format = "ssh";

      help.autocorrect = 1;

      init.defaultBranch = "main";

      merge.conflictStyle = "diff3";

      mergetool.nixfmt = {
        cmd = "nixfmt --mergetool \"$BASE\" \"$LOCAL\" \"$REMOTE\" \"$MERGED\"";
        trustExitCode = true;
      };

      pull.rebase = true;

      push = {
        default = "current";
        followTags = true;
      };

      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      tag = {
        gpgSign = true;
        sort = "version:refname";
      };
    };

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "ayu_dark";
    };
  };

  programs.nh = {
    enable = true;
    flake = "/etc/nix-darwin";
    clean.enable = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  home.file = {
    ".hushlogin".text = "";
  };
}
