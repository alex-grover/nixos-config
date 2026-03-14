{ pkgs, configPath, ... }:
{
  home.packages = [
    pkgs.ghostty.terminfo
  ];

  programs.fish.interactiveShellInit = ''
    if test "$TERM" = xterm-ghostty
      source "${pkgs.ghostty.shell_integration}/fish/vendor_conf.d/ghostty-shell-integration.fish"
    end
  '';
}
