{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.catppuccin) accent flavor;

  # The same palette file catppuccin's own modules read, so the selector
  # follows theme.nix rather than hardcoding mocha hexes. slurp takes
  # #RRGGBBAA.
  palette = (lib.importJSON "${config.catppuccin.sources.palette}/palette.json").${flavor}.colors;

  saveDir = "${config.home.homeDirectory}/Pictures/Screenshots";

  # A shell wrapper rather than the pipeline inline in a sway binding, for two
  # reasons: slurp exits non-zero when the selection is cancelled with escape,
  # and grim handed an empty geometry writes an error where the PNG should be;
  # and the capture is staged through a file rather than a pipe so that
  # cancelling leaves swappy unopened instead of showing it an empty stdin.
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      slurp
      swappy
    ];
    text = ''
      mkdir -p ${lib.escapeShellArg saveDir}

      shot=$(mktemp --tmpdir screenshot-XXXXXXXX.png)
      trap 'rm -f "$shot"' EXIT

      # Redirected rather than piped: a pipeline would run this in a subshell,
      # where the cancel below would exit that subshell and let swappy open on
      # a zero-byte file anyway.
      case "''${1:-region}" in
        region)
          # -b dims the rest of the screen; the selection itself is left clear
          # and gets the accent border sway uses on the focused window.
          geometry=$(slurp \
            -b "${palette.crust.hex}99" \
            -c "${palette.${accent}.hex}ff" \
            -s "#00000000" \
            -w 2) || exit 0
          grim -g "$geometry" -
          ;;
        screen)
          # No -o: there is one output, and grim with neither flag captures the
          # whole layout, which stays right if a second monitor ever appears.
          grim -
          ;;
        *)
          echo "usage: screenshot [region|screen]" >&2
          exit 1
          ;;
      esac > "$shot"

      swappy -f "$shot"
    '';
  };
in
{
  # Print and Shift+Print are bound in sway.nix, by name — `screenshot` is on
  # PATH through home.packages, the same way the helium binding there works.
  home.packages = [ screenshot ];

  # The annotation step. swappy over satty deliberately: satty is GTK 4, which
  # gtk.nix explicitly does not theme (see the gtk4.theme comment there), while
  # swappy is GTK 3 and picks up the catppuccin widget theme like thunar does.
  programs.swappy = {
    enable = true;
    settings.Default = {
      # swappy expands neither ~ nor $HOME reliably across versions, so this is
      # the literal path the wrapper above creates.
      save_dir = saveDir;
      save_filename_format = "screenshot-%Y%m%d-%H%M%S.png";

      # The toolbar is the only way to reach the annotation tools, and this is
      # not a program that gets used often enough to remember the shortcuts.
      show_panel = true;

      # Matches the UI font, not the terminal one: swappy renders these into
      # the image, where a mono face reads as a code comment on a screenshot.
      text_font = "sans-serif";
      text_size = 20;
      line_size = 5;

      # Nothing is written until save is pressed, so a screenshot taken by
      # accident leaves nothing behind. Ctrl+C copies to the clipboard instead
      # — but nothing manages clipboard history here by choice, and swappy owns
      # the selection while it runs, so paste it before closing the window.
      auto_save = false;
      early_exit = false;
    };
  };
}
