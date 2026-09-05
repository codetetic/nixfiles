{ ... }:
{
  catppuccin = {
    flavor = "mocha";
    accent = "mauve";

    enable = false;

    btop.enable = true;
    fzf.enable = true;
    fish.enable = true;
    starship.enable = true;
    ghostty.enable = true;
    imv.enable = true;
    mako.enable = true;
    rofi.enable = true;
    sway.enable = true;
    swaylock.enable = true;
    waybar.enable = true;
    yazi.enable = true;

    # GNOME was setting the pointer theme; with it gone, nothing does, and the
    # cursor falls back to the X11 default that changes shape between
    # toolkits. This has no `enable` upstream to piggyback on, so unlike the
    # rest it is opted into rather than following catppuccin.enable.
    cursors.enable = true;

    # Only the icon theme: catppuccin.gtk.enable was removed from the flake
    # after the upstream GTK port was archived, so there is no widget theme to
    # turn on here. This is what colours thunar's sidebar and folder icons; the
    # widget theme that replaces the archived port, and the gtk.enable that
    # makes both this and cursors above actually reach a GTK app, are in
    # src/home/gtk.nix.
    gtk.icon.enable = true;

    # The Qt counterpart, and the better half of the two: the Kvantum theme is
    # catppuccin's own, so Qt apps get mocha widgets rather than the
    # third-party port GTK has to make do with. It is inert without
    # qt.enable and asserts qt.style.name = "kvantum"; both are in
    # src/home/qt.nix.
    kvantum.enable = true;
  };
}
