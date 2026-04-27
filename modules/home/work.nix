{ pkgs, ... }:
{
  home.packages = [
    pkgs.claude-code
    pkgs.codex
    pkgs.slack
    pkgs.zoom-us
  ];
}
