{ pkgs, ... }:

{
  home.packages = with pkgs; [
    dig
    silver-searcher
    devenv
    nixd
    nixfmt-rfc-style
  ];
}
