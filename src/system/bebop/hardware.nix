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

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/460B-0617";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/c2ae3fd2-cede-4f08-9453-0b55bea1b7e7";
      randomEncryption.enable = true;
    }
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    vulkan-tools
    openrgb-with-all-plugins
    lm_sensors
  ];

  # CPU
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.lact = {
    enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
  };

  # Networking
  networking = {
    hostId = "4b3c47ff";
    hostName = "bebop";
  };

  # RAM
  hardware.i2c.enable = true;
  services = {
    hardware.openrgb.enable = true;
    udev.packages = [ pkgs.openrgb ];
  };
}