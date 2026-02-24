{
  self,
  pkgs,
  user,
  host,
  system,
  ...
}:
{
  nix.settings.experimental-features = "nix-command flakes";
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = system;
  networking.hostName = host;
  system.primaryUser = user;
  users.knownUsers = [ user ];
  users.users.${user} = {
    uid = 501;
    home = "/Users/${user}";
    shell = pkgs.fish;
  };
  nixpkgs.config.allowUnfree = true;
  programs.fish.enable = true;

  homebrew = {
    enable = true;

    casks = [
      "logi-options+"
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
