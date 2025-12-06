{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Bootloader
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  # Filesystems
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B9A2-EE13";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/2a6b40c4-bb62-4734-85b3-017f0222c313";
      randomEncryption.enable = true;
    }
  ];

  # CPU
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Networking
  networking = {
    hostId = "18857cad";
    hostName = "odyssey";
  };
}
