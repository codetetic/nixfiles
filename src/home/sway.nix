{ lib, pkgs, ... }:
{
  # Dwindle tiling. Sway only creates a split container when asked, so without
  # this every new window keeps appending to the same row. autotiling watches
  # the IPC socket and issues splith/splitv on the focused window before the
  # next one opens, picking whichever axis is longer: on DP-2 the first window
  # fills the screen, the second splits it left/right, the third top/bottom,
  # and so on. The -rs port is used over the original to avoid a Python
  # runtime in the closure; nothing needs it on PATH because the unit below
  # references its store path directly.
  services.autotiling = {
    enable = true;
    package = pkgs.autotiling-rs;
    # sway-session.target is what the sway module starts and stops, so the
    # service tracks the compositor rather than the wider graphical session.
    systemdTarget = "sway-session.target";
  };

  wayland.windowManager.sway = {
    # Sway itself is installed by the NixOS module (programs.sway); home-manager
    # only owns ~/.config/sway/config, which takes precedence over /etc/sway/config.
    package = null;

    # corner_radius and smart_corner_radius are SwayFX extensions, so there is
    # no home-manager option for them; smart_corner_radius leaves a lone
    # window's corners square. See programs.sway.package in configuration.nix.
    extraConfig = ''
      corner_radius 8
      smart_corner_radius on
    '';

    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      # Bound to the default mod+d.
      menu = "rofi -show drun";

      # wpaperd owns the background now (see wallpaper.nix); this just pins the
      # BenQ to its native mode.
      output."DP-2".mode = "2560x1440";

      input."type:keyboard".xkb_layout = "gb";

      # A little breathing room between tiles, and the same again against the
      # screen edge so the rounded corners are not clipped by it.
      gaps = {
        inner = 8;
        outer = 4;
      };

      # Waybar already shows the focused window's title, so sway draws a plain
      # border instead of a titlebar. The floating half still matters with
      # nothing floated by hand: scratchpad windows, and dialogs that set a
      # floating window type, are shown floating regardless.
      window.titlebar = false;
      floating.titlebar = false;

      # app_id, not class: both run natively on wayland via NIXOS_OZONE_WL.
      assigns = {
        "3" = [ { app_id = "codium"; } ];
        "9" = [ { app_id = "discord"; } ];
      };

      # Sway otherwise comes up focused on an empty workspace 10. Nothing in
      # this config asks for that, so rather than chase the cause this just
      # claims workspace 1 once the config has finished loading. Plain exec,
      # not exec_always, so a config reload does not yank focus.
      startup = [ { command = "swaymsg workspace 1"; } ];
      # Sway's defaults, minus the layout and scratchpad bindings, plus the
      # four below.
      # Sway's defaults, minus the layout bindings, plus the two below.
      keybindings = lib.mkOptionDefault {
        # No manually floated windows, so the two space bindings drive the
        # scratchpad instead. Their defaults were "floating toggle" and
        # "focus mode_toggle", and with nothing floated by hand there is no
        # floating layer to toggle or jump to. Windows that float themselves,
        # and the scratchpad itself, are unaffected.
        "Mod4+Shift+space" = "move scratchpad";
        "Mod4+space" = "scratchpad show";

        # Sway's own scratchpad bindings, dropped so the space pair above is
        # the only route to it.
        "Mod4+Shift+minus" = null;
        "Mod4+minus" = null;

        # Layout switching, all off. Tabbed and stacking always draw a title
        # bar that default_border pixel cannot suppress, so fat-fingering one
        # puts a 22px bar between the windows; autotiling (see above) picks
        # the split axis, which leaves the split bindings redundant too.
        "Mod4+b" = null;
        "Mod4+v" = null;
        "Mod4+s" = null;
        "Mod4+w" = null;
        "Mod4+e" = null;

        # Cycle workspaces; not a sway default.
        "Mod4+Tab" = "workspace next";
        "Mod4+Shift+Tab" = "workspace prev";

        # Browser, to go with mod+return for the terminal. helium comes from
        # a flake input, see src/system/bebop/home.nix.
        "Mod4+BackSpace" = "exec helium";

        # Lock now. swayidle already locks on idle and before sleep (see
        # swaylock.nix); this is the manual route. Escape rather than a letter
        # because mod+shift+{h,j,k,l} are taken by the move bindings.
        "Mod4+Escape" = "exec swaylock -f";

        # Screenshots. `screenshot` is the wrapper from screenshot.nix, on
        # PATH like helium above; both routes end in swappy for annotation.
        # Region is the unshifted one because it is the common case.
        "Print" = "exec screenshot region";
        "Shift+Print" = "exec screenshot screen";
      };

      # $-variables come from the catppuccin sway theme, which theme.nix
      # includes ahead of this config. The focused window (border and
      # titlebar) is the accent purple; everything else stays muted.
      colors = {
        background = "$base";
        focused = {
          border = "$mauve";
          background = "$mauve";
          text = "$base";
          indicator = "$lavender";
          childBorder = "$mauve";
        };
        focusedInactive = {
          border = "$surface0";
          background = "$surface0";
          text = "$text";
          indicator = "$surface0";
          childBorder = "$surface0";
        };
        unfocused = {
          border = "$mantle";
          background = "$mantle";
          text = "$subtext0";
          indicator = "$mantle";
          childBorder = "$mantle";
        };
        urgent = {
          border = "$red";
          background = "$red";
          text = "$base";
          indicator = "$red";
          childBorder = "$red";
        };
        placeholder = {
          border = "$base";
          background = "$base";
          text = "$text";
          indicator = "$base";
          childBorder = "$base";
        };
      };

      # Replaced by waybar, see waybar.nix. An empty list stops sway from
      # launching swaybar as well.
      bars = [ ];
    };
  };
}
