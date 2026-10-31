{
  pkgs,
  config,
  inputs,
  user,
  ...
}:
let
  keys = import ../lib/keys.nix;
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.rex.nixosModules.default
  ];

  age.identityPaths = [ "/home/${user}/.ssh/id_ed25519" ];
  age.secrets.rex-netrc.file = ../secrets/rex-netrc.age;

  nix.settings.netrc-file = config.age.secrets.rex-netrc.path;
  services.rex.loginServer = {
    enable = true;
    tailscaleServe.enable = true;
    accounts.${user}.principals = [ "tailscale:hello@alexgrover.me" ];
  };

  system.stateVersion = "25.11";

  time.timeZone = "America/New_York";

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
      extraGroups = [
        "wheel"
        "transmission"
      ];
      openssh.authorizedKeys.keys = builtins.attrValues keys;
    };
  };
}
