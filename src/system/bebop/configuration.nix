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
  programs.sleepy-launcher = {
    enable = true;
  };

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

  # AI
  services.ollama = {
    enable = true;
    acceleration = "rocm";
  };

  # Flatpak
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "com.vivaldi.Vivaldi"
      "com.discordapp.Discord"
      "com.transmissionbt.Transmission"
      "io.openrct2.OpenRCT2"
      "us.zoom.Zoom"
    ];
    update.onActivation = true;
  };

  # Services
  services = {
    ratbagd.enable = true;
  };
}
