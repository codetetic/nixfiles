{ ... }:
{
  programs.rofi = {
    # Wayland support is in the main rofi package now; rofi-wayland was merged in.
    terminal = "ghostty";
    font = "FiraCode Nerd Font 12";

    extraConfig = {
      modes = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
    };
  };
}
