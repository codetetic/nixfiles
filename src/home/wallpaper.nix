{ config, ... }:
{
  # Replaces the static swaybg background set by sway.nix.
  services.wpaperd = {
    settings.default = {
      path = "${config.home.homeDirectory}/Pictures/wallpapers";
      duration = "30m";
      sorting = "random";
      # DP-2 is 2560x1440, so images at that size fill it exactly; anything
      # else is letterboxed rather than cropped or stretched.
      mode = "fit";
    };
  };
}
