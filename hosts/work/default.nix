{ lib, ... }:
{
  homebrew.casks = [ "okta-verify" ];

  system.defaults.dock.persistent-apps = lib.mkOrder 1250 [
    "/Applications/Slack.app"
  ];
}
