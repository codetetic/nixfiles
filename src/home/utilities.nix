{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    ncdu
    pwgen
    fastfetch
  ];
}
