{
  inputs,
  pkgs,
  ...
}:
{
  system.stateVersion = "26.05";
  hardware.enableRedistributableFirmware = true;

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  services.openssh.enable = true;

  services.tailscale.useRoutingFeatures = "server";
}
