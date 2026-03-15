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
  shares = {
    media = "/data/media";
    torrents = "/data/torrents";
  };
  vpnIpv4 = "10.2.0.2";
  vpnIpv6 = "2a07:b944::2:2";
  vpnTable = "51820";
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  age.secrets.smtp.file = ../../secrets/smtp.age;
  age.secrets.vpn.file = ../../secrets/vpn.age;
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

  systemd.tmpfiles.settings =
    builtins.mapAttrs (_: path: {
      ${path}.z = {
        inherit user;
        group = "users";
        mode = "0755";
      };
    }) shares
    // {
      transmission = {
        "/data/torrents/transmission".z = {
          user = "transmission";
          group = "transmission";
          mode = "2775";
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
    }
    // builtins.mapAttrs (_: path: {
      inherit path;
      browseable = "yes";
      writeable = "yes";
      "valid users" = user;
    }) shares;
  };

  services.avahi = {
    enable = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.tailscale.useRoutingFeatures = "server";

  networking.wireguard.interfaces.vpn = {
    ips = [
      "${vpnIpv4}/32"
      "${vpnIpv6}/128"
    ];
    privateKeyFile = config.age.secrets.vpn.path;
    table = vpnTable;
    postSetup = ''
      ${pkgs.iproute2}/bin/ip rule add from ${vpnIpv4} table ${vpnTable}
      ${pkgs.iproute2}/bin/ip -6 rule add from ${vpnIpv6} table ${vpnTable}
    '';
    postShutdown = ''
      ${pkgs.iproute2}/bin/ip rule del from ${vpnIpv4} table ${vpnTable}
      ${pkgs.iproute2}/bin/ip -6 rule del from ${vpnIpv6} table ${vpnTable}
    '';
    peers = [
      {
        publicKey = "R8Of+lrl8DgOQmO6kcjlX7SchP4ncvbY90MB7ZUNmD8=";
        endpoint = "193.148.18.82:51820";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
      }
    ];
  };

  services.transmission = {
    enable = true;
    openFirewall = true;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
      bind-address-ipv4 = vpnIpv4;
      bind-address-ipv6 = vpnIpv6;
      download-dir = "/data/torrents/transmission/downloads";
      incomplete-dir = "/data/torrents/transmission/incomplete";
      umask = 2;
    };
  };
}
