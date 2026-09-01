{ config, lib, ... }:
{
  # Shared font settings, so ghostty, rofi, waybar and vscodium can't drift
  # apart. The size is stated once in points; sizePx below converts it for the
  # consumers that want pixels, which is what kept ghostty and vscodium
  # looking different despite both reading the same number.
  options.local.fonts.mono = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "FiraCode Nerd Font";
      description = "Monospace family used by the terminal, editor and launcher.";
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = 12;
      description = ''
        Default monospace size, in points. Use this for anything that takes a
        typographic size: ghostty's font-size, rofi's pango font string.
      '';
    };

    sizePx = lib.mkOption {
      type = lib.types.int;
      readOnly = true;
      description = ''
        {option}`size` in CSS pixels, for consumers that measure that way:
        vscodium (an electron app, so its fontSize is CSS px) and waybar's
        stylesheet. Do not set this; it is derived from {option}`size`.
      '';
    };
  };

  # 96/72 is the reference CSS DPI. It holds because DP-2 runs at scale 1.0;
  # a fractional-scaled output would still be fine, as both toolkits apply the
  # scale on top of these numbers rather than expecting them pre-scaled.
  config.local.fonts.mono.sizePx =
    builtins.floor (config.local.fonts.mono.size * 96.0 / 72.0 + 0.5);
}
