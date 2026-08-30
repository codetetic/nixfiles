{ lib, pkgs, ... }:
{
  # Everything the config below shells out to. pactl comes from the pulseaudio
  # in programs.sway.extraPackages.
  home.packages = with pkgs; [
    brightnessctl
    grim
    playerctl
    slurp
    swaybg
    wl-clipboard
  ];

  wayland.windowManager.sway = {
    # Sway itself is installed by the NixOS module (programs.sway); home-manager
    # only owns ~/.config/sway/config, which takes precedence over /etc/sway/config.
    package = null;

    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "rofi -show drun";

      # Home row direction keys, like vim.
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      output."*".bg =
        "/run/current-system/sw/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill";

      input."type:keyboard".xkb_layout = "gb";

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

      bars = [
        {
          position = "top";
          statusCommand = "while date +'%Y-%m-%d %X'; do sleep 1; done";
          colors = {
            statusline = "#ffffff";
            background = "#323232";
            inactiveWorkspace = {
              border = "#32323200";
              background = "#32323200";
              text = "#5c5c5c";
            };
          };
        }
      ];
    };
  };
}
