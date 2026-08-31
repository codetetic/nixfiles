{ ... }:
{
  # catppuccin.enable is left off deliberately: with it set, every port whose
  # program is enabled would be themed. Each module below is opted into by
  # hand instead, and inherits catppuccin.flavor (mocha) and
  # catppuccin.accent (mauve) from the defaults.
  catppuccin = {
    flavor = "mocha";
    accent = "mauve";

    sway.enable = true;
    waybar.enable = true;
    rofi.enable = true;
  };
}
