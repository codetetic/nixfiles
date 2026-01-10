{
  user,
  pkgs,
  inputs,
  ...
}:

{
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
  imports = [
    inputs.aagl.nixosModules.default
  ];
  nix.settings = inputs.aagl.nixConfig;
}
