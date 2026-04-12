{
  user,
  ...
}:

{
  # System
  system.autoUpgrade = {
    enable = false;
  };

  # Virtualisation
  virtualisation = {
    docker.enable = false;
    podman.enable = true;
    libvirtd.enable = true;
  };
  users.users.${user.name}.extraGroups = [
    "docker"
    "podman"
    "libvirtd"
  ];

  services = {
    flatpak.enable = true;
    ratbagd.enable = true;
  };
}
