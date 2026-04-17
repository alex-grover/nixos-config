{ pkgs, ... }:
{
  home.packages = [
    pkgs.codex
    pkgs.nodejs_22
    pkgs.slack
    pkgs.zoom-us
  ];
}
