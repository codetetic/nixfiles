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
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Filesystems
  boot.supportedFilesystems = [ "zfs" ];

  fileSystems."/" = {
    device = "tank/root";
    fsType = "zfs";
  };
  fileSystems."/nix" = {
    device = "tank/nix";
    fsType = "zfs";
  };
  fileSystems."/var" = {
    device = "tank/var";
    fsType = "zfs";
  };
  fileSystems."/home" = {
    device = "tank/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/51CC-06ED";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/59cce7dd-3409-48ce-90db-0e7d143dfe9f";
      randomEncryption.enable = true;
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

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
}
