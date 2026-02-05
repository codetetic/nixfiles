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
    docker.enable = true;
    podman.enable = true;
    libvirtd.enable = true;
  };
  users.users.${user.name}.extraGroups = [
    "docker"
    "podman"
    "libvirtd"
  ];
}
