{ pkgs, ... }:

{
  home.packages = with pkgs; [
    dig
    silver-searcher
    nixd
    nixfmt-rfc-style
  ];
}
