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
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    libvirtd.enable = true;
  };
  users.users.${user.name}.extraGroups = [
    "docker"
    "podman"
    "libvirtd"
  ];
  # Allow podman to use port 80
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

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
      "org.mozilla.firefox"
      "com.google.Chrome"
      "com.getpostman.Postman"
      "org.gimp.GIMP"
      "org.keepassxc.KeePassXC"
      "org.libreoffice.LibreOffice"
      "org.freedesktop.Piper"
      "us.zoom.Zoom"
    ];
    update.onActivation = true;
  };

  services = {
    ratbagd.enable = true;
  };
}
