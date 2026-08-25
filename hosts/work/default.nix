{ lib, ... }:
{
  homebrew.masApps."Okta Verify" = 490179405;

  system.defaults.dock.persistent-apps = lib.mkOrder 1250 [
    "/Applications/Slack.app"
  ];
}
