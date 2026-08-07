{ pkgs, ... }:
{
  home.packages = [
    pkgs.datadog-pup
    pkgs.linear
  ];
}
