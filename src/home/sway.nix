{ lib, pkgs, ... }:
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

  wayland.windowManager.sway = {
    # Sway itself is installed by the NixOS module (programs.sway); home-manager
    # only owns ~/.config/sway/config, which takes precedence over /etc/sway/config.
    package = null;

    extraConfig = "default_orientation horizontal";

    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "rofi -show drun";

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

      # app_id, not class: vscodium runs natively on wayland via NIXOS_OZONE_WL.
      assigns."3" = [ { app_id = "codium"; } ];

      # Everything sway binds by default is kept; these are the extras.
      keybindings = lib.mkOptionDefault {
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
