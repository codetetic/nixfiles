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
  programs.sleepy-launcher = {
    enable = true;
  };

  # Services
  services.flatpak = {
    enable = true;
  };
}
