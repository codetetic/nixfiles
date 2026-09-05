{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (config.gtk) iconTheme theme;
in
# services.flatpak is a NixOS option, so it is read through osConfig — this
# whole file is dead weight on a host that never turns flatpak on.
lib.mkIf osConfig.services.flatpak.enable {
  # A flatpak app is in its own mount namespace: it sees the runtime's
  # /usr/share/themes and its own $HOME view, and nothing of the host store. So
  # the settings.ini gtk.nix writes names a theme the sandbox cannot open, and
  # the app falls back to Adwaita however well the host is themed.
  #
  # Three pieces have to line up. First, the theme and icons have to exist
  # somewhere GTK looks *inside* the sandbox: $XDG_DATA_HOME/{themes,icons} is
  # searched there as it is here, and home-manager only puts these in the nix
  # profile, which is not on the sandbox's XDG_DATA_DIRS. The cursor theme is
  # already linked here by home.pointerCursor, hence no entry for it.
  xdg.dataFile = {
    "themes/${theme.name}".source = "${theme.package}/share/themes/${theme.name}";
    "icons/${iconTheme.name}".source = "${iconTheme.package}/share/icons/${iconTheme.name}";

    # Second, the sandbox has to be allowed to read them. `flatpak override`
    # writes exactly this file — [Context] with semicolon-separated lists — so
    # a global override can be declared rather than run by hand. Overrides in
    # the user installation apply to everything this user launches, including
    # apps installed into the system installation by the unit in
    # src/system/bebop/configuration.nix.
    #
    # /nix/store is the awkward one: the two entries above are symlinks into
    # it, and a symlink whose target is not mounted is a dangling one inside
    # the sandbox. It is exposed read-only, and the store is world-readable
    # already, so this grants no more than the ability to read a public
    # directory — but it is why this file is theming only and not a pattern to
    # extend.
    "flatpak/overrides/global".text = ''
      [Context]
      filesystems=xdg-data/themes:ro;xdg-data/icons:ro;xdg-config/gtk-3.0:ro;xdg-config/gtk-4.0:ro;/nix/store:ro
    '';
  };

  # Third, the app has to be told which theme to use. That half already works:
  # programs.dconf plus the gtk module put the theme, icon and cursor names in
  # org/gnome/desktop/interface, and xdg-desktop-portal-gtk serves those over
  # the settings portal, which is where a sandboxed GTK app reads its settings
  # from. The gtk-3.0:ro entry above is belt and braces for anything that
  # bypasses the portal.
}
