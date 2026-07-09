{ lib, ... }:
{
  homebrew.casks = [
    "claude-code"
    "codex"
    "linear-linear"
    "okta-verify"
  ];

  system.defaults.dock.persistent-apps = lib.mkOrder 1250 [
    "/Applications/Slack.app"
  ];
}
