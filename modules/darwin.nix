{
  lib,
  config,
  pkgs,
  user,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nixpkgs.config.allowUnfree = true;
  documentation.enable = false;
  system.tools.darwin-uninstaller.enable = false;
  programs.zsh.enable = false;

  nix-homebrew = {
    enable = true;
    inherit user;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
    # Required by Homebrew, but not yet exported by nix-homebrew's launcher.
    extraEnv.HOMEBREW_ORIGINAL_BREW_FILE = "${config.nix-homebrew.defaultArm64Prefix}/bin/brew";
  };

  # Rex isn't packaged for macOS, so install it from its Sparkle appcast if it's
  # missing; the app keeps itself up to date after that. Runs before the dock is
  # configured so its tile resolves on first activation.
  #
  # NOT REPRODUCIBLE: this always installs whatever build is newest in the
  # snapshot appcast at activation time. The version isn't pinned by
  # flake.lock, and rolling back this config doesn't change the installed app.
  system.activationScripts.extraActivation.text =
    let
      installRex = pkgs.writeShellScript "install-rex" ''
        set -euo pipefail
        app=/Applications/Rex.app
        [ -e "$app" ] && exit 0

        echo "installing Rex..." >&2
        tmp=$(mktemp -d)
        trap '/usr/bin/hdiutil detach -quiet "$tmp/mnt" 2>/dev/null || true; rm -rf "$tmp"' EXIT
        url=$(/usr/bin/curl -fsSL https://blob.superlogical.com/public/rex-app/snapshot/appcast.xml \
          | grep -o 'enclosure url="[^"]*"' | head -1 | cut -d'"' -f2)
        /usr/bin/curl -fsSL -o "$tmp/rex.dmg" "$url"
        mkdir "$tmp/mnt"
        /usr/bin/hdiutil attach -quiet -nobrowse -readonly -noautoopen -mountpoint "$tmp/mnt" "$tmp/rex.dmg"
        /usr/bin/codesign --verify --deep --strict \
          -R='anchor apple generic and certificate leaf[subject.OU] = "AG92C3PT77"' "$tmp/mnt/Rex.app"
        # curl doesn't quarantine the download, so Gatekeeper won't check it on
        # first launch; run its notarization check here instead.
        /usr/sbin/spctl --assess --type execute "$tmp/mnt/Rex.app"
        /usr/bin/ditto "$tmp/mnt/Rex.app" "$app"
        # Owned by the user so Sparkle can update it without a password prompt.
        chown -R ${user}:staff "$app"
      '';
    in
    ''
      ${installRex} || echo "warning: failed to install Rex" >&2
    '';

  system.stateVersion = 6;
  system.primaryUser = user;
  users.knownUsers = [ user ];
  users.users.${user} = {
    uid = 501;
    home = "/Users/${user}";
    shell = pkgs.fish;
  };
  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    global.autoUpdate = false;

    casks = [
      "alcove"
      "logi-options+"
      "raycast"
      "tailscale-app"
    ];

    masApps = {
      "uBlock Origin Lite" = 6745342698;
    };

    onActivation = {
      cleanup = "zap";
      upgrade = true;
    };
  };

  system.startup.chime = false;
  system.defaults = {
    CustomUserPreferences = {
      AppleFirstWeekday = {
        gregorian = 2;
      };
      "com.apple.Safari" = {
        IncludeDevelopMenu = true;
        ShowFavoritesBar = false;
      };
      "com.apple.menuextra.clock" = {
        Show24Hour = true;
      };
    };
    NSGlobalDomain = {
      AppleFontSmoothing = 0;
      AppleInterfaceStyleSwitchesAutomatically = true;
      KeyRepeat = 1;
      InitialKeyRepeat = 30;
      "com.apple.swipescrolldirection" = false;
      "com.apple.trackpad.scaling" = 2.0;
    };
    ".GlobalPreferences"."com.apple.mouse.scaling" = 1.5;
    controlcenter = {
      BatteryShowPercentage = false;
      NowPlaying = false;
    };
    dock = {
      autohide = true;
      mru-spaces = false;
      showMissionControlGestureEnabled = true;
      show-recents = false;
      persistent-apps = lib.mkMerge [
        [
          "/System/Applications/Calendar.app"
          "/System/Applications/Mail.app"
          "/System/Cryptexes/App/System/Applications/Safari.app"
          "/System/Applications/Reminders.app"
          "/System/Applications/Messages.app"
          "/Applications/Rex.app"
        ]
        (lib.mkAfter [
          "/Users/${user}/Applications/Home Manager Apps/Spotify.app"
          "/System/Applications/System Settings.app"
        ])
      ];
      wvous-br-corner = 4;
      wvous-tl-corner = 10;
      wvous-tr-corner = 2;
    };
    finder = {
      FXPreferredViewStyle = "clmv";
      ShowExternalHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
    };
    trackpad = {
      TrackpadRightClick = true;
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
    };
    iCal."TimeZone support enabled" = true;
    loginwindow = {
      GuestEnabled = false;
      autoLoginUser = user;
    };
  };
}
