{ pkgs, ... }:
{
  home.packages = [
    pkgs.herdr
    pkgs.linear
  ];
}
