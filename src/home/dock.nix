{ pkgs, ... }:
{
  # An auto-hiding dock along the bottom edge, in the macOS mould: nothing is
  # drawn until the pointer reaches the bottom of the screen.
  #
  # nwg-dock is the sway-native one; nwg-dock-hyprland is a separate fork. No
  # home-manager module exists for it, so the unit is written out by hand and
  # follows the autotiling service in sway.nix.
  #
  #   -d          auto-hide; the dock appears when the bottom hotspot is hovered
  #   -nolauncher rofi is already on mod+space, and the launcher button draws
  #               images/grid.svg, which the nixpkgs package does not install
  #   -nows       waybar already lists the workspaces along the top
  systemd.user.services.nwg-dock = {
    Unit = {
      Description = "Auto-hiding application dock";
      PartOf = [ "sway-session.target" ];
      After = [ "sway-session.target" ];
    };

    Service = {
      Type = "simple";
      Restart = "always";
      ExecStart = "${pkgs.nwg-dock}/bin/nwg-dock -d -nolauncher -nows";
    };

    Install.WantedBy = [ "sway-session.target" ];
  };

  # nwg-dock reads its stylesheet from ~/.config/nwg-dock and otherwise copies
  # a default out of /usr/share/nwg-dock, which does not exist on NixOS: the
  # package installs the binary alone. Without this file the dock falls back to
  # unstyled GTK grey.
  #
  # The colours are catppuccin mocha written out literally. There is no
  # catppuccin port for nwg-dock, so unlike waybar these cannot be inherited
  # and must be changed by hand if catppuccin.flavor in theme.nix changes.
  xdg.configFile."nwg-dock/style.css".text = ''
    @define-color surface0 #313244;
    @define-color text     #cdd6f4;
    @define-color mauve    #cba6f7;

    /* Mantle at 85%, so the wallpaper shows through the way the macOS dock
       lets the desktop through. */
    window {
      background-color: rgba(24, 24, 37, 0.85);
      border: 1px solid @surface0;
      border-radius: 14px;
      margin: 8px;
    }

    /* The hotspot is the invisible strip along the bottom edge that exists
       the whole time the dock is hidden. nwg-dock normally styles it from
       /usr/share/nwg-dock/hotspot.css, which is missing here, so it is pinned
       transparent explicitly: otherwise it inherits the window rule above and
       sits on screen as a permanent bar. */
    #hotspot,
    #hotspot-box {
      background-color: transparent;
      border: none;
      margin: 0;
    }

    button {
      background: none;
      border: none;
      border-radius: 10px;
      padding: 4px;
      margin: 2px;
    }

    button:hover {
      background-color: @surface0;
    }
  '';
}
