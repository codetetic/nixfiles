{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.catppuccin) accent flavor;

  # `Catppuccin-GTK` builds mocha as its plain dark theme and latte as its
  # light one; frappe and macchiato are recolour tweaks layered on the dark
  # build rather than variants of their own.
  shade = if flavor == "latte" then "light" else "dark";
  tweaks = lib.optional (flavor == "frappe" || flavor == "macchiato") flavor;

  # themes/install.sh names the directory it installs
  # "${name}${theme}${color}${size}${ctype}", where every part after the name
  # already carries its leading dash and `standard` size contributes nothing.
  # gtk.theme.name has to match that exactly or GTK silently falls back to
  # Adwaita.
  themeName =
    "Catppuccin-GTK-${lib.toSentenceCase accent}-${lib.toSentenceCase shade}"
    + lib.concatMapStrings (t: "-${lib.toSentenceCase t}") tweaks;
in
{
  # Nothing was writing ~/.config/gtk-3.0/settings.ini, which is the only
  # channel a GTK app has for this outside a desktop environment's XSETTINGS
  # daemon: thunar came up in stock light Adwaita with stock icons, and the
  # icon and cursor themes opted into in theme.nix were inert because
  # home-manager only emits them under gtk.enable.
  gtk = {
    enable = true;

    # catppuccin/nix dropped its GTK module when the upstream port was
    # archived (see theme.nix), so the widget theme comes from a third-party
    # port that is still maintained. It is driven off catppuccin.flavor/accent
    # like nixvim's colorscheme so a palette change is still a one-line edit.
    theme = {
      name = themeName;
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ accent ];
        inherit shade tweaks;
      };
    };

    # Writes gtk-application-prefer-dark-theme, which is what stops GTK
    # picking the light stylesheet out of a theme that ships both, and the
    # matching color-scheme key for libadwaita apps.
    colorScheme = if flavor == "latte" then "light" else "dark";

    # Stated rather than left to default: home-manager changed this to null in
    # 26.05 and warns until it is pinned either way. GTK 4 ignores
    # gtk-theme-name, so home-manager themes it by @importing the theme's
    # gtk-4.0/gtk.css from ~/.config/gtk-4.0/gtk.css — but that CSS reaches for
    # its images by a path relative to the importing file, so the assets
    # directory beside it in the store is missed and a GTK 4 app ends up
    # half-themed. thunar is GTK 3 and nothing here is libadwaita, so take
    # the new default; colorScheme above still gets those apps a dark Adwaita
    # rather than a light one.
    gtk4.theme = null;

    # No gtk.font: GTK's built-in default is "Sans 10", and
    # fonts.fontconfig.defaultFonts in src/system/configuration.nix already
    # resolves Sans to Noto Sans. Naming it again here would be a second place
    # to keep in step for no gain.
  };

  # catppuccin.cursors in theme.nix only sets home.pointerCursor, which is
  # backend-independent; the GTK half is opt-in and is what puts
  # gtk-cursor-theme-name in settings.ini.
  home.pointerCursor.gtk.enable = true;
}
