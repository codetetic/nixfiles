{
  user,
  pkgs,
  ...
}:

{
  # System
  system.autoUpgrade = {
    enable = true;
  };

  # Virtualisation
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };
  users.users.${user.name}.extraGroups = [ "podman" ];

  # Programmes
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # Services
  services.flatpak = {
    enable = true;
  };
}
