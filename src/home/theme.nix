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
    mako.enable = true;
    rofi.enable = true;
    sway.enable = true;
    waybar.enable = true;
    yazi.enable = true;

    # GNOME was setting the pointer theme; with it gone, nothing does, and the
    # cursor falls back to the X11 default that changes shape between
    # toolkits. This has no `enable` upstream to piggyback on, so unlike the
    # rest it is opted into rather than following catppuccin.enable.
    cursors.enable = true;

    # Only the icon theme: catppuccin.gtk.enable was removed from the flake
    # after the upstream GTK port was archived, so there is no widget theme to
    # turn on. This is what colours thunar's sidebar and folder icons.
    gtk.icon.enable = true;
  };
}
