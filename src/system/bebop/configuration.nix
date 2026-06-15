{
  user,
  pkgs,
  inputs,
  ...
}:

{
  # Programmes
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      gamescope
      proton-ge-bin
      inputs.dw-proton.packages.${pkgs.system}.default
    ];
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.yubikey-manager.enable = true;

  # Virtualisation
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    libvirtd.enable = true;
  };
  users.users.${user.name}.extraGroups = [
    "podman"
    "libvirtd"
    "plugdev"
  ];
  # Allow podman to use port 80
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  # Services
  services = {
    ratbagd.enable = true;
  };
}
