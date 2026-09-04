{ config, ... }:
let
  font = config.local.fonts.mono;
in
{
  programs.imv.settings = {
    options = {
      # The wallpaper filenames carry their title and credit, so keep the
      # overlay up by default — it is the only place that information is
      # visible once a file is open.
      overlay = true;
      overlay_font = "${font.name} ${toString font.size}";

      # Scale down anything larger than the window but never blow up a small
      # image to fit, which is imv's default and makes screenshots mushy.
      scaling_mode = "shrink";

      # Nearest-neighbour once past 1:1, so pixel art and zoomed-in
      # screenshots stay legible rather than being smeared by the filter.
      upscaling_method = "nearest_neighbour";
    };
  };
}
