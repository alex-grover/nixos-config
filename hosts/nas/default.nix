{
  config,
  inputs,
  pkgs,
  name,
  user,
  ...
}:
let
  email = "hello@alexgrover.me";
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  age.secrets.smtp.file = ../../secrets/smtp.age;
  age.secrets.zfs.file = ../../secrets/zfs.age;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "cb3aedbe";

  services.fstrim.enable = true;

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    accounts.default = {
      auth = true;
      tls = true;
      tls_starttls = true;
      host = "smtp.mail.me.com";
      port = 587;
      user = email;
      passwordeval = "cat ${config.age.secrets.smtp.path}";
      from = email;
    };
  };

  services.smartd = {
    enable = true;
    notifications.mail = {
      enable = true;
      sender = email;
      recipient = email;
    };
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    zed = {
      enableMail = true;
      settings = {
        ZED_EMAIL_ADDR = [ email ];
        ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
      };
    };
  };

  systemd.tmpfiles.settings.media = {
    "/data/media" = {
      z = {
        inherit user;
        group = "users";
        mode = "0755";
      };
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "server string" = name;
        security = "user";
        "server min protocol" = "SMB3";
        "vfs objects" = "fruit streams_xattr";
      };
      media = {
        path = "/data/media";
        browseable = "yes";
        writeable = "yes";
        "valid users" = user;
      };
    };
  };

  services.avahi = {
    enable = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
