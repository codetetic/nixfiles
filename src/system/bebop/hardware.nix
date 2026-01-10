{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.kernelModules = [
    "kvm-amd"
    "i2c-dev"
    "i2c-piix4"
  ];
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/460B-0617";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/c2ae3fd2-cede-4f08-9453-0b55bea1b7e7";
      randomEncryption.enable = true;
    }
  ];

  # CPU
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  systemd.services.bluetooth-reset = {
    description = "Reset Bluetooth controller after power-on";
    after = [ "bluetooth.service" ];
    wantedBy = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bluez}/bin/btmgmt power off";
      ExecStartPost = "${pkgs.bluez}/bin/btmgmt power on";
    };
  };

  # Networking
  networking = {
    hostId = "4b3c47ff";
    hostName = "bebop";
  };

  # RAM
  hardware.i2c.enable = true;
  services.hardware.openrgb.enable = true;
  services.udev.packages = [ pkgs.openrgb ];
}
