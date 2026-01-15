{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    pwgen
    fastfetch
    usbutils
  ];
}
