{ config, pkgs, ... }:
let
  font = config.local.fonts.mono;
in
{
  # The notification daemon. Nothing was implementing
  # org.freedesktop.Notifications before this, so notifications from discord,
  # spotify-player and friends were being dropped on the floor. mako is
  # started on demand: home-manager installs its D-Bus service file, and
  # sway's systemd integration has already handed WAYLAND_DISPLAY to the
  # activation environment by the time anything sends one.
  services.mako = {
    enable = true;

    settings = {
      # Same corner radius and border width as sway's windows, so a
      # notification reads as one more tile rather than a foreign popup.
      # See corner_radius in sway.nix.
      border-radius = 8;
      border-size = 2;

      # Top-right, below waybar: mako is a layer-shell surface on the same
      # layer as the bar, so it is pushed clear of waybar's exclusive zone
      # without the bar's height being repeated here. The margin matches
      # sway's inner gap.
      anchor = "top-right";
      layer = "top";
      margin = 8;
      padding = 12;

      width = 380;
      height = 160;

      font = "${font.name} ${toString font.size}";
      markup = true;
      # Discord and the like send an app icon; 48px keeps it in proportion
      # with two lines of text at the size above.
      icons = true;
      max-icon-size = 48;

      # mako's own default is 0, which never expires anything and leaves the
      # corner of the screen to be cleared by hand.
      default-timeout = 5000;

      # One notification per app on screen at a time, the rest stacked behind
      # it, so a chatty app cannot fill the column.
      group-by = "app-name";

      # Colours come from catppuccin.mako, which theme.nix enables: the module
      # drops an `include` of the mocha/mauve palette into this same file, so
      # the border picks up the accent that sway gives the focused window.
      # Everything above is deliberately colour-free so the two do not fight.
      # That palette also gives urgent notifications a peach border via an
      # [urgency=high] section; "high" is mako's alias for critical, so this
      # section stacks on top of it rather than replacing it, and anything
      # urgent stays up until dismissed.
      "urgency=critical".default-timeout = 0;
    };
  };

  # notify-send, to exercise the daemon without waiting for an app to raise
  # something. makoctl comes with mako itself.
  home.packages = [ pkgs.libnotify ];
}
