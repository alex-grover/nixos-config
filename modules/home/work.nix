{ pkgs, ... }:
{
  home.packages = [
    pkgs.claude-code
    pkgs.nodejs_22
    pkgs.slack
    pkgs.zoom-us
  ];
}
