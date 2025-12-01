{
  lib,
  ...
}:

{
  options.zfsFilesystems = lib.mkOption {
    type = lib.types.functionTo lib.types.attrs;
    description = "Function to generate ZFS filesystem configuration";
  };

  config.zfsFilesystems = { poolName, bootUuid, swapPartuuid }:
    {
      boot.supportedFilesystems = [ "zfs" ];

      fileSystems."/" = {
        device = "${poolName}/root";
        fsType = "zfs";
      };
      fileSystems."/nix" = {
        device = "${poolName}/nix";
        fsType = "zfs";
      };
      fileSystems."/var" = {
        device = "${poolName}/var";
        fsType = "zfs";
      };
      fileSystems."/home" = {
        device = "${poolName}/home";
        fsType = "zfs";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/${bootUuid}";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };
      swapDevices = [
        {
          device = "/dev/disk/by-partuuid/${swapPartuuid}";
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
    };
}
