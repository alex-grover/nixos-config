{ pkgs, ... }:
{
  home.packages = [
    pkgs.claude-code
    pkgs.codex
    pkgs.nodejs_22
    pkgs.slack
    pkgs.zoom-us
  ];
}
