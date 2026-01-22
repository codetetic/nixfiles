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
  };
  programs.sleepy-launcher = {
    enable = true;
  };

  # Virtualisation
  virtualisation = {
    virtualbox.host.enable = true;
  };

  # Groups
  users.users.${user.name}.extraGroups = [ "vboxusers" ];

  # Flatpak
  services = {
    flatpak.enable = true;
  };
}
