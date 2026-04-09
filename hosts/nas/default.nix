{
  config,
  inputs,
  lib,
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
  photosDomain = "photos.alexgrover.me";
  dashboardServices = [
    {
      name = "Radarr";
      port = 7878;
    }
    {
      name = "Sonarr";
      port = 8989;
    }
    {
      name = "Prowlarr";
      port = 9696;
    }
    {
      name = "Transmission";
      port = 9091;
    }
  ];
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  age.secrets.smtp.file = ../../secrets/smtp.age;
  age.secrets.vercel.file = ../../secrets/vercel.age;
  age.secrets.vpn.file = ../../secrets/vpn.age;
  age.secrets.zfs.file = ../../secrets/zfs.age;

  security.acme = {
    acceptTerms = true;
    defaults.email = email;
    certs = lib.genAttrs [ "nas.alexgrover.me" photosDomain ] (_: {
      dnsProvider = "vercel";
      credentialFiles.VERCEL_API_TOKEN_FILE = config.age.secrets.vercel.path;
    });
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "cb3aedbe";

  systemd.services.zfs-load-key-data-media = {
    description = "Load ZFS encryption key for data/media";
    requires = [ "zfs-import-data.service" ];
    after = [ "zfs-import-data.service" ];
    before = [ "zfs-mount.service" ];
    requiredBy = [ "zfs-mount.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "zfs-load-key-data-media" ''
        if [ "$(${pkgs.zfs}/bin/zfs get -H -o value keystatus data/media)" = "unavailable" ]; then
          ${pkgs.zfs}/bin/zfs load-key data/media
        fi
      '';
    };
  };

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
      immich = {
        "/data/media/immich".z = {
          user = "immich";
          group = "immich";
          mode = "0700";
        };
      };
      radarr = {
        "/data/torrents/movies".d = {
          user = "radarr";
          group = "radarr";
          mode = "2775";
        };
      };
      sonarr = {
        "/data/torrents/tv shows".d = {
          user = "sonarr";
          group = "sonarr";
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

  services.glance = {
    enable = true;
    settings = {
      branding.hide-footer = true;
      theme = {
        light = false;
        background-color = "220 29 6";
        primary-color = "105 61 62";
        positive-color = "80 65 57";
        negative-color = "357 81 69";
        contrast-multiplier = 1.1;
      };
      pages = [
        {
          name = "Home";
          width = "slim";
          hide-desktop-navigation = true;
          center-vertically = true;
          columns = [
            {
              size = "full";
              widgets = [
                { type = "clock"; }
                {
                  type = "server-stats";
                  servers = [
                    {
                      type = "local";
                      hide-swap = true;
                      mountpoints = {
                        "/" = {
                          name = "Root";
                          hide = false;
                        };
                        "/data/media" = {
                          name = "Media";
                          hide = false;
                        };
                      };
                      hide-mountpoints-by-default = true;
                    }
                  ];
                }
                {
                  type = "monitor";
                  title = "Services";
                  cache = "1m";
                  sites =
                    map (s: {
                      title = s.name;
                      url = "https://nas.alexgrover.me/${lib.toLower s.name}";
                      icon = "di:${lib.toLower s.name}";
                    }) dashboardServices
                    ++ [
                      {
                        title = "Immich";
                        url = "https://${photosDomain}";
                        icon = "di:immich";
                      }
                    ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts.${photosDomain} = {
      useACMEHost = photosDomain;
      extraConfig = ''
        reverse_proxy [::1]:${toString config.services.immich.port}
      '';
    };
    virtualHosts."nas.alexgrover.me" = {
      useACMEHost = "nas.alexgrover.me";
      extraConfig =
        lib.concatMapStrings (s: ''
          handle /${lib.toLower s.name}* {
            reverse_proxy 127.0.0.1:${toString s.port}
          }
        '') dashboardServices
        + ''
          handle {
            reverse_proxy 127.0.0.1:8080
          }
        '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  hardware.graphics.enable = true;

  services.immich = {
    enable = true;
    mediaLocation = "/data/media/immich";
    accelerationDevices = null;
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  services.radarr.enable = true;
  services.sonarr.enable = true;
  services.prowlarr.enable = true;

  users.users.radarr.extraGroups = [ "transmission" ];
  users.users.sonarr.extraGroups = [ "transmission" ];
  users.users.${user}.extraGroups = [
    "radarr"
    "sonarr"
  ];

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
      ratio-limit = 0;
      ratio-limit-enabled = true;
      umask = 2;
    };
  };
}
