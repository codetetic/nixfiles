{ lib, ... }:
{
  # Shared font settings, so ghostty, rofi and vscodium can't drift apart.
  options.local.fonts.mono = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "FiraCode Nerd Font";
      description = "Monospace family used by the terminal, editor and launcher.";
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = 14;
      description = "Default monospace point size.";
    };
  };
}
