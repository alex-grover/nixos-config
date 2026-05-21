{ lib, ... }:
{
  homebrew.casks = [
    "linear-linear"
  ];

  system.defaults.dock.persistent-apps = lib.mkOrder 1250 [
    "/Applications/Slack.app"
  ];
}
