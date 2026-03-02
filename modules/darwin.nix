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

  nix-homebrew = {
    enable = true;
    inherit user;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };

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

    casks = [
      "logi-options+"
      "tailscale-app"
    ];

    masApps = {
      "uBlock Origin Lite" = 6745342698;
    };

    onActivation = {
      cleanup = "zap";
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
          "/System/Applications/Notes.app"
          "/System/Applications/Messages.app"
          "/Users/${user}/Applications/Home Manager Apps/WebStorm.app"
          "/Users/${user}/Applications/Home Manager Apps/Ghostty.app"
        ]
        (lib.mkAfter [
          "/Users/${user}/Applications/Home Manager Apps/Spotify.app"
          "/System/Applications/System Settings.app"
        ])
      ];
      wvous-br-corner = 2;
      wvous-tl-corner = 10;
      wvous-tr-corner = 4;
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
