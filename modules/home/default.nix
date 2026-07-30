{
  pkgs,
  user,
  configPath,
  ...
}:
let
  nnnOpener = pkgs.writeShellScriptBin "nnn-opener" ''
    target=$1
    mime=$(${pkgs.file}/bin/file -biL -- "$target")
    editor=''${VISUAL:-''${EDITOR:-vi}}
    desktop_opener=''${NNN_DESKTOP_OPENER:-/usr/bin/open}

    edit() {
      # Allow simple editor commands with arguments, e.g. VISUAL='hx --log /tmp/hx.log'.
      # shellcheck disable=SC2086
      exec $editor "$target"
    }

    open_desktop() {
      exec "$desktop_opener" "$target"
    }

    case "$mime" in
      text/* | \
      application/ecmascript* | \
      application/javascript* | \
      application/json* | \
      application/toml* | \
      application/typescript* | \
      application/xml* | \
      application/x-ecmascript* | \
      application/x-javascript* | \
      application/x-typescript* | \
      application/x-yaml*)
        edit
        ;;
      image/* | audio/* | video/* | application/pdf*)
        open_desktop
        ;;
    esac

    case "$target" in
      *.bash | *.c | *.cc | *.conf | *.cpp | *.css | *.env | *.fish | *.go | \
      *.h | *.hpp | *.html | *.js | *.jsx | *.jsonc | *.lua | *.md | *.mdx | \
      *.mjs | *.nix | *.rs | *.sh | *.toml | *.ts | *.tsx | *.txt | *.xml | \
      *.yaml | *.yml | *.zsh)
        edit
        ;;
    esac

    open_desktop
  '';
in
{
  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
  home.username = user;

  home.packages = [
    pkgs.fd
    pkgs.hunk
    pkgs.jj-starship
    pkgs.ripgrep
  ];

  home.sessionVariables = {
    ADBLOCK = "1";
    DISABLE_OPENCOLLECTIVE = "true";
    NNN_OPENER = "${nnnOpener}/bin/nnn-opener";
  };

  programs.bat.enable = true;

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
    silent = true;
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
      editor = {
        auto-format = true;
        bufferline = "multiple";
        color-modes = true;
        cursorline = true;
        line-number = "relative";
        file-picker = {
          hidden = false;
          ignore = true;
          git-ignore = true;
        };
      };
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
        git_push_bookmark = "\"alex/\" ++ change_id.shortest(8)";
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
        diff-formatter = ":git";
        merge-editor = ":builtin";
        pager = [
          "hunk"
          "pager"
        ];
      };
    };
  };

  programs.nh = {
    enable = true;
    flake = configPath;
    clean.enable = true;
  };

  programs.nnn = {
    enable = true;
    enableFishIntegration = true;
    options.c = true;
    quitcd = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command_timeout = 1000;
      nix_shell.symbol = "❄️ ";
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
