{
  user,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.aagl.nixosModules.default
  ];
  nix.settings = inputs.aagl.nixConfig;

  # System
  system.autoUpgrade = {
    enable = true;
  };

  # Programmes
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      inputs.dw-proton.packages.x86_64-linux.default
    ];
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.sleepy-launcher = {
    enable = true;
  };

  # Virtualisation
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    libvirtd.enable = true;
  };
  users.users.${user.name}.extraGroups = [
    "docker"
    "podman"
    "libvirtd"
  ];

  # Flatpak
  services = {
    flatpak.enable = true;
  };
}
