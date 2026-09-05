{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pwgen
    fastfetch
    usbutils
  ];

  # Enabled through its home-manager module rather than listed as a package
  # above, which is what it was before and why it came out unthemed. The
  # catppuccin module is gated on `catppuccin.btop.enable && programs.btop.enable`,
  # so with btop installed as a bare package the theme half silently did
  # nothing: no theme file written, no color_theme set, and no warning either.
  # Installing a package is not enough for anything opted into in theme.nix —
  # the program's own home-manager module has to be enabled too.
  programs.btop.enable = true;
}
