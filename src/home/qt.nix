{ config, ... }:
{
  # Nothing in the package set is Qt-heavy today, so this is groundwork rather
  # than a fix: with qt.enable off, the first Qt app installed comes up in
  # default Fusion light next to an otherwise mocha desktop. Enabled here
  # rather than in src/system/bebop/home.nix for the same reason gtk.nix is —
  # it is toolkit plumbing with no program behind it to list in that inventory.
  qt = {
    enable = true;

    # qt5ct/qt6ct rather than the "gtk" platform theme the TODO sketched: that
    # one bridges through qtstyleplugins, which is a GTK2-era plugin, and its
    # Qt 6 half (qt6gtk2) reads GTK2 settings that nothing on this machine
    # writes. qtct owns the palette itself, which is also what catppuccin's
    # Kvantum theme expects to be sitting behind it.
    platformTheme.name = "qtct";

    # Kvantum is an SVG-based style engine for Qt, and catppuccin/nix ships a
    # theme for it — so unlike GTK (see gtk.nix, where the upstream port is
    # archived and the theme comes from a third party) the Qt side gets real
    # mocha widgets from the flake. catppuccin.kvantum in theme.nix installs
    # the theme and asserts this is set to "kvantum".
    style.name = "kvantum";

    # Qt has no notion of the GTK icon theme, so the name has to be stated
    # again — read out of gtk.iconTheme, which catppuccin.gtk.icon sets, rather
    # than spelled out, so the two cannot drift. Kvantum styles widgets only;
    # icons are still looked up through the freedesktop theme spec.
    #
    # No Fonts section, for the same reason gtk.nix sets no font: Qt resolves
    # its default through fontconfig, and fonts.fontconfig.defaultFonts in
    # src/system/configuration.nix already points Sans at Noto Sans.
    qt5ctSettings.Appearance.icon_theme = config.gtk.iconTheme.name;
    qt6ctSettings.Appearance.icon_theme = config.gtk.iconTheme.name;
  };
}
