{
  ...
}:

{
  # Bootloader
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.initrd.systemd.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  # Filesystems
  # See: https://blog.hetherington.uk/2025/02/installing-nixos-on-a-thinkpad-t480s-with-encrypted-zfs-2/
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
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  # Hardware
  hardware.enableAllFirmware = true;
}
