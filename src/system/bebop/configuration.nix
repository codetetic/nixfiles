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
    ];
  };
  programs.sleepy-launcher = {
    enable = true;
  };

  users.users.${user.name}.extraGroups = [ "plugdev" ];
}
