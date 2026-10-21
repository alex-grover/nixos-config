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
    pkgs.delta
    pkgs.fd
    pkgs.ripgrep
    pkgs.typescript-language-server
  ];

  home.sessionVariables = {
    ADBLOCK = "1";
    DISABLE_OPENCOLLECTIVE = "true";
    DELTA_PAGER = "less -FRXK";
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

  xdg.configFile."kak/colors/monokai_extended.kak".source = ./kakoune/monokai_extended.kak;

  programs.gh.enable = true;

  programs.git.enable = true;

  programs.kakoune = {
    enable = true;
    defaultEditor = true;
    plugins = [
      pkgs.kakounePlugins.kakoune-lsp
      jjGutter
    ];
    config.colorScheme = "monokai_extended";
    extraConfig = ''
      alias global bd delete-buffer
      alias global bd! delete-buffer!
      add-highlighter global/ number-lines -relative -hlcursor -min-digits 4 -separator '  '
      eval %sh{kak-lsp}
      add-highlighter global/cursor-line line '%val{cursor_line}' CursorLine
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

      define-command -hidden -params 1.. copy-system %{
        nop %sh{
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
      define-command yank-system -docstring 'Copy selections to the system clipboard' %{
        copy-system %val{selections}
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

      define-command yank-github-link -docstring 'Copy a GitHub link at the nearest known pushed ancestor for the main selected lines' %{
        evaluate-commands %sh{
          fail() { printf "fail '%s'\n" "$1"; exit 0; }
          jj_read() { jj --ignore-working-copy --at-operation=@ --no-pager --color=never "$@"; }
          case "$kak_buffile" in /*) ;; *) fail 'Select lines in a file buffer.' ;; esac
          dir=''${kak_buffile%/*}; path=''${kak_buffile##*/}
          [ -n "$dir" ] || dir=/
          while [ ! -d "$dir" ]; do
            path=''${dir##*/}/$path; dir=''${dir%/*}
            [ -n "$dir" ] || dir=/
          done
          cd -P "$dir" 2>/dev/null || fail 'Cannot access the file directory.'
          root=$(jj_read workspace root 2>/dev/null) || fail 'File is outside a jj workspace.'
          here=$(pwd -P); root=''${root%/}; path=''${here%/}/$path
          case "$path" in "$root"/*) path=''${path#"$root"/} ;; *) fail 'File is outside the workspace root.' ;; esac
          revision='latest(heads((::@ & ::remote_bookmarks(remote=origin)) ~ root()))'
          base=$(jj_read log -r "$revision" --no-graph -T 'git_web_url() ++ "/blob/" ++ commit_id') || fail 'Cannot resolve a pushed jj revision.'
          [ -n "$base" ] || fail 'No pushed ancestor is known on origin. Run jj git fetch first.'
          case "$base" in https://github.com/*/blob/*) ;; *) fail 'A GitHub origin is required.' ;; esac
          path=$(printf '%s' "$path" | od -An -v -tu1 | awk '{
            for (i=1; i<=NF; i++) {
              n=$i
              if ((n>=65 && n<=90) || (n>=97 && n<=122) || (n>=48 && n<=57) || n==45 || n==46 || n==47 || n==95 || n==126)
                printf "%c", n
              else printf "%%%02X", n
            }
          }')
          first=''${kak_selection_desc%%.*}; last=''${kak_selection_desc#*,}; last=''${last%%.*}
          if [ "$first" -gt "$last" ]; then swap=$first; first=$last; last=$swap; fi
          range=L$first
          [ "$first" -eq "$last" ] || range=$range-L$last
          quote="'"
          printf "copy-system '%s'\n" "$(printf '%s' "$base/$path#$range" | sed "s/$quote/$quote$quote/g")"
        }
      }
      map global user g ':yank-github-link<ret>' -docstring 'Copy GitHub link'

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
          "delta"
          "--paging=always"
          "--line-numbers"
          "--navigate"
          "--file-modified-label=modified: "
          "--navigate-regex=^(modified:|added:|removed:|renamed:|copied:)"
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
      format = "$directory$vcs$nix_shell$cmd_duration$line_break$jobs$status$character";
      nix_shell.symbol = "❄️ ";
      vcs = {
        order = [
          "jj"
          "git"
        ];
        git_modules = "$git_branch$git_commit$git_state$git_status";
        jj_modules = "$jj_change\${custom.jj_distance}([\\[$jj_status\${custom.jj_state}\\]](red) )";
      };
      jj_change = {
        change_hash_length = 8;
        prefix_style = "bright-purple";
        suffix_style = "bright-black";
        format = "on [󱗆](blue) $change ";
      };
      jj_status = {
        # The outer brackets live in vcs.jj_modules so native and custom flags
        # share one status group. The native module supplies ! for conflicts.
        format = "$conflicted";
      };
      custom = {
        jj_distance = {
          # Invoked only after $vcs has detected a JJ repository.
          # Read the existing snapshot without creating operations.
          when = true;
          shell = [ "sh" ];
          command = "${pkgs.runtimeShell} ${./starship-jj.sh} bookmarks";
          format = "([\\($output\\)](green) )";
        };
        jj_state = {
          when = true;
          shell = [ "sh" ];
          command = "${pkgs.runtimeShell} ${./starship-jj.sh} state";
          format = "$output";
        };
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
