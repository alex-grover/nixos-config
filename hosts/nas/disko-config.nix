{ config, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-128GB_SSD_MQ49W66505063";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };

      data1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST6000VN006-2ZM186_ZVX08DRG";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };

      data2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST6000VN006-2ZM186_ZVX09G45";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };
    };

    zpool = {
      data = {
        type = "zpool";
        mode = "mirror";
        mountpoint = null;
        options.ashift = "12";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
          normalization = "formD";
          xattr = "sa";
        };
        datasets = {
          media = {
            type = "zfs_fs";
            mountpoint = "/data/media";
            options = {
              recordsize = "1M";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file://${config.age.secrets.zfs.path}";
              "com.sun:auto-snapshot" = "true";
            };
          };
          torrents = {
            type = "zfs_fs";
            mountpoint = "/data/torrents";
            options.recordsize = "1M";
          };
        };
      };
    };
  };
}
