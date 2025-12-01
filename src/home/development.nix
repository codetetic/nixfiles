{ pkgs, ... }:

{
  home.packages = with pkgs; [
    silver-searcher
    devenv
    nixd
    nixfmt-rfc-style
  ];
}
