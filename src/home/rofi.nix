{ config, ... }:
{
  programs.rofi = {
    # Wayland support is in the main rofi package now; rofi-wayland was merged in.
    terminal = "ghostty";
    # Deliberately a couple of points smaller than the terminal/editor size.
    font = "${config.local.fonts.mono.name} 12";

    extraConfig = {
      modes = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
    };
  };
}
