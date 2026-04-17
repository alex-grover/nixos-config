{ lib, user, ... }:
{
  homebrew.casks = [
    "claude-code@latest"
    "linear-linear"
  ];

  system.defaults.dock.persistent-apps = lib.mkOrder 1250 [
    "/Users/${user}/Applications/Home Manager Apps/Slack.app"
  ];
}
