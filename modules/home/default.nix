{
  pkgs,
  user,
  configPath,
  ...
}:
let
  defaultDesktopOpener = if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/open" else "";

  jjGutter = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "alex-grover";
    repo = "jj-gutter.kak";
    rev = "180a14df34a093cd2bcd6d0603b5852893eb8dd6";
    hash = "sha256-C4h5aiKXkZRCTSVORxrLxNjFevaNmPBHGNvpicV0lMU=";
  }) { };

  nnnOpener = pkgs.writeShellScriptBin "nnn-opener" ''
    target=$1
    mime=$(${pkgs.file}/bin/file -biL -- "$target")
    editor=''${VISUAL:-''${EDITOR:-vi}}
    desktop_opener=''${NNN_DESKTOP_OPENER:-${defaultDesktopOpener}}

    edit() {
      # Allow simple editor commands with arguments, e.g. VISUAL='kak -c main'.
      # shellcheck disable=SC2086
      exec $editor "$target"
    }

    open_desktop() {
      if [ -z "$desktop_opener" ]; then
        printf 'nnn-opener: cannot open non-text file: %s\nSet NNN_DESKTOP_OPENER to use a custom opener.\n' "$target" >&2
        exit 1
      fi
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
    pkgs.typescript-language-server
  ];

  home.sessionVariables = {
    ADBLOCK = "1";
    DISABLE_OPENCOLLECTIVE = "true";
    HUNK_TEXT_PAGER = "less -FRXK";
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

  programs.kakoune = {
    enable = true;
    defaultEditor = true;
    plugins = [
      pkgs.kakounePlugins.kakoune-lsp
      jjGutter
    ];
    colorSchemePackage = pkgs.kakounePlugins.kakoune-catppuccin;
    config.colorScheme = "catppuccin_mocha";
    extraConfig = ''
      alias global bd delete-buffer
      alias global bd! delete-buffer!
      add-highlighter global/ number-lines -relative -hlcursor -min-digits 4 -separator '  '
      eval %sh{kak-lsp}
      set-face global DiagnosticError default,default,rgb:f38ba8+c
      set-face global DiagnosticWarning default,default,rgb:f9e2af+c
      add-highlighter global/cursor-line line '%val{cursor_line}' default,rgb:313244
      set-option global modelinefmt '{{mode_info}} %val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}}'
      jj-enable
      alias global jjb jj-blame-toggle

      hook global WinSetOption filetype=(javascript|typescript) %{
        lsp-enable-window
        hook -group semantic-tokens window BufReload .* lsp-semantic-tokens
        hook -group semantic-tokens window NormalIdle .* lsp-semantic-tokens
        hook -group semantic-tokens window InsertIdle .* lsp-semantic-tokens
        hook -once -always window WinSetOption filetype=.* %{
          remove-hooks window semantic-tokens
        }
      }
      map global user l ':enter-user-mode lsp<ret>' -docstring 'LSP'

      define-command yank-system -docstring 'Copy selections to the system clipboard' %{
        nop %sh{
          eval set -- "$kak_quoted_selections"
          copy() {
            printf '%s' "$1"
            shift
            for selection do printf '\n%s' "$selection"; done
          }
          if [ -z "$kak_client_env_SSH_CONNECTION" ] && command -v pbcopy >/dev/null 2>&1; then
            copy "$@" | pbcopy
          else
            tty=$(ps -o tty= -p "$kak_client_pid" | tr -d '[:space:]')
            [ -n "$tty" ] && [ "$tty" != '?' ] || exit 1
            printf '\033]52;c;%s\007' "$(copy "$@" | base64 | tr -d '\n')" > "/dev/$tty"
          fi
        }
      }
      define-command paste-system -docstring 'Paste the system clipboard after selections' %{
        evaluate-commands %sh{
          if [ -n "$kak_client_env_SSH_CONNECTION" ] || ! command -v pbpaste >/dev/null 2>&1; then
            printf '%s\n' "fail 'On a remote/headless host, enter insert mode and use terminal paste.'"
          else
            printf '%s\n' 'execute-keys -draft "<a-!>pbpaste<ret>"'
          fi
        }
      }
      map global user y ':yank-system<ret>' -docstring 'Copy to system clipboard'
      map global user p ':paste-system<ret>' -docstring 'Paste system clipboard'

      define-command file-picker %{
        prompt -menu -shell-script-candidates 'fd --type f --hidden --no-require-git --exclude .jj --exclude .git' 'file: ' %{ edit -existing %val{text} }
      }
      define-command buffer-picker %{
        prompt -menu -buffer-completion 'buffer: ' %{ buffer %val{text} }
      }
      set-option global grepcmd %{rg --vimgrep --smart-case --hidden --no-require-git --glob '!.jj/**' --glob '!.git/**'}
      define-command project-search %{
        prompt 'search: ' %{ grep -- %val{text} . }
      }
      map global user f ':file-picker<ret>' -docstring 'Find file'
      map global user b ':buffer-picker<ret>' -docstring 'Switch buffer'
      map global user / ':project-search<ret>' -docstring 'Search project'
    '';
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
        log = "builtin_log_compact ++ diff.summary()";
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

  programs.tmux = {
    enable = true;
    mouse = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    secureSocket = false;
    extraConfig = ''
      set -g status off
      set -g copy-mode-position-format ""
      set -g pane-border-indicators off
      set -g pane-border-style 'fg=#3a3a3a'
      set -g pane-active-border-style 'fg=#3a3a3a'
      set -s default-client-command 'new-session -A -s main'
      set -s extended-keys on
      set -s extended-keys-format csi-u
      set -s set-clipboard on
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };
}
