{ config, ... }:
{
  programs.rofi = {
    # Wayland support is in the main rofi package now; rofi-wayland was merged in.
    terminal = "ghostty";
    # Deliberately a couple of points smaller than the terminal/editor size.
    font = "${config.local.fonts.mono.name} ${toString config.local.fonts.mono.size}";

    # The theme itself comes from catppuccin.rofi, see theme.nix.
    extraConfig = {
      modes = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
    };
  };
}
