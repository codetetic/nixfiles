{ lib, pkgs, ... }:
let
  # Shared by config.menu and the mod+a binding below.
  menu = "rofi -show drun";
in
{
  # Everything the config below shells out to. pactl comes from the pulseaudio
  # in programs.sway.extraPackages.
  home.packages = with pkgs; [
    brightnessctl
    grim
    playerctl
    slurp
    wl-clipboard
  ];

  # Dwindle tiling. Sway only creates a split container when asked, so without
  # this every new window keeps appending to the same row. autotiling watches
  # the IPC socket and issues splith/splitv on the focused window before the
  # next one opens, picking whichever axis is longer: on DP-2 the first window
  # fills the screen, the second splits it left/right, the third top/bottom,
  # and so on. The -rs port is used over the original to avoid a Python
  # runtime in the closure; the package is not in home.packages because the
  # unit below references its store path directly.
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
      default_orientation horizontal
      corner_radius 8
      smart_corner_radius on
    '';

    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      inherit menu;

      # Home row direction keys, like vim.
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      # wpaperd owns the background now (see wallpaper.nix); this just pins the
      # BenQ to its native mode.
      output."DP-2".mode = "2560x1440";

      input."type:keyboard".xkb_layout = "gb";

      # New containers split left/right instead of sway's aspect-ratio-based
      # "auto", and workspaces stay in the plain tiled layout.
      workspaceLayout = "default";

      # A little breathing room between tiles, and the same again against the
      # screen edge so the rounded corners are not clipped by it.
      gaps = {
        inner = 8;
        outer = 4;
      };

      # Waybar already shows the focused window's title, so sway draws a plain
      # border instead of a titlebar on both tiled and floating windows.
      window = {
        titlebar = false;
        border = 2;
      };
      # Still needed with mod+shift+space unbound: sway shows scratchpad
      # windows floating, and dialogs that set a floating window type get it
      # whether or not anything is bound.
      floating = {
        titlebar = false;
        border = 2;
      };

      # app_id, not class: vscodium runs natively on wayland via NIXOS_OZONE_WL.
      assigns."3" = [ { app_id = "codium"; } ];

      # Sway otherwise comes up focused on an empty workspace 10. Nothing in
      # this config asks for that, so rather than chase the cause this just
      # claims workspace 1 once the config has finished loading. Plain exec,
      # not exec_always, so a config reload does not yank focus.
      startup = [ { command = "swaymsg workspace 1"; } ];

      # Everything sway binds by default is kept; these are the extras.
      keybindings = lib.mkOptionDefault {
        # Launcher on mod+space, the way spotlight sits on cmd+space; null
        # drops sway's mod+d. This takes over mod+space's default
        # "focus mode_toggle" (jump between the tiled and floating layers);
        # mod+shift+space still toggles a window's floating state.
        "Mod4+space" = "exec ${menu}";
        "Mod4+d" = null;

        # No manually floated windows; the scratchpad (mod+shift+minus to
        # stash, mod+minus to show) covers the same need. Windows that float
        # themselves, and the scratchpad itself, are unaffected.
        "Mod4+Shift+space" = null;

        # Sway always draws a title bar for tabbed and stacking containers,
        # which default_border pixel cannot suppress, so fat-fingering these
        # puts a 22px bar between the windows. Split layouts only.
        "Mod4+s" = null;
        "Mod4+w" = null;

        # Volume, via PulseAudio.
        "--locked XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "--locked XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "--locked XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "--locked XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";

        # Media, via playerctl.
        "--locked XF86AudioPlay" = "exec playerctl play-pause";
        "--locked XF86AudioPause" = "exec playerctl play-pause";
        "--locked XF86AudioPrev" = "exec playerctl previous";
        "--locked XF86AudioNext" = "exec playerctl next";
        "--locked XF86AudioStop" = "exec playerctl stop";

        # Brightness.
        "--locked XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "--locked XF86MonBrightnessUp" = "exec brightnessctl set 5%+";

        # Screenshots to the clipboard: whole output, or a selected region.
        "Print" = "exec grim - | wl-copy";
        "Shift+Print" = ''exec grim -g "$(slurp)" - | wl-copy'';
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
