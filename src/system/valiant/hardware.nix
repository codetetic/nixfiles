{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "rtsx_pci_sdmmc"
    "i915"
  ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" "iwlwifi" ];
  boot.extraModulePackages = [ ];
  boot.loader.efi.canTouchEfiVariables = true;

  # Filesystems
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/51CC-06ED";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/59cce7dd-3409-48ce-90db-0e7d143dfe9f";
      randomEncryption.enable = true;
    }
  ];

  # CPU
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services.thermald.enable = true;

  # GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  services.xserver = {
    videoDrivers = [ "modesetting" ];
  };

  # Networking
  networking = {
    hostId = "4b3c47ff";
    hostName = "valiant";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };
  hardware.enableAllFirmware = true;
}
