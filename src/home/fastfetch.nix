{ config, lib, ... }:
let
  # Read the palette out of the catppuccin flake rather than pasting hex codes,
  # so flavor and accent in theme.nix stay the single source of truth and a
  # palette change does not have to be repeated here. This is import-from-
  # derivation: the palette is a fetched source, not a build, so it costs a
  # store fetch on first eval and nothing after.
  palette =
    (lib.importJSON "${config.catppuccin.sources.palette}/palette.json")
    .${config.catppuccin.flavor}.colors;

  # fastfetch wants bare SGR parameters, not a full escape sequence.
  ansi =
    name:
    let
      c = palette.${name}.rgb;
    in
    "38;2;${toString c.r};${toString c.g};${toString c.b}";

  accent = ansi config.catppuccin.accent;
in
{
  # fastfetch has neither a catppuccin module nor a home-manager one, so it is
  # the tier-2 case from CLAUDE.md: colours set from its own config, driven off
  # config.catppuccin.flavor the way nixvim.nix does it.
  #
  # Only the logo and key colours need setting. Everything else fastfetch
  # prints already resolves through the terminal's 16 ANSI colours, which are
  # themed by ghostty and catppuccin.tty — without this it was only the accent
  # that was off, not the whole output.
  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

    logo.color = {
      "1" = accent;
      "2" = ansi "blue";
    };

    display.color = {
      keys = accent;
      title = accent;
    };
  };
}
