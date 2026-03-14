{
  pkgs,
  inputs,
  user,
  ...
}:
let
  keys = import ../lib/keys.nix;
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  age.identityPaths = [ "/home/${user}/.ssh/id_ed25519" ];

  time.timeZone = "America/New_York";

  networking.useDHCP = true;

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ user ];
      PrintLastLog = "no";
    };
  };

  services.tailscale.enable = true;

  users = {
    mutableUsers = false;
    users.${user} = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        keys.personal
        keys.phone
        keys.work
      ];
    };
  };
}
