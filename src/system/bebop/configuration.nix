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
}
