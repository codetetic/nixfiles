{ config, ... }:
let
  font = config.local.fonts.mono;
in
{
  # Replaces sway's built-in swaybar, which sway.nix now disables.
  programs.waybar = {
    # Started by sway-session.target rather than by sway's `bar` command.
    systemd.enable = true;

    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "pulseaudio"
          "power-profiles-daemon"
          "cpu"
          "memory"
          "network"
          "tray"
          "clock"
        ];

        "sway/workspaces".disable-scroll = true;
        "sway/mode".format = "<span style=\"italic\">{}</span>";
        "sway/window".max-length = 80;

        # Same format and once-a-second tick as the old `date` statusCommand.
        clock = {
          interval = 1;
          format = "{:%Y-%m-%d %X}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        # Reads and writes power-profiles-daemon over the system bus (enabled in
        # src/system/configuration.nix), so it shows whichever profile swayidle
        # left behind as well as one set by hand. Left click steps forward
        # through the profiles, right click back; the same polkit rule that lets
        # swayidle switch is what makes those clicks work, as waybar is a
        # systemd --user service too.
        #
        # Icon only, one speedometer at three speeds: the bar is already busy
        # and the profile rarely changes. waybar's own default tooltip already
        # spells out the profile and the driver behind it, so it is left alone.
        power-profiles-daemon = {
          format = "{icon}";
          format-icons = {
            default = "󰾅";
            performance = "󰓅";
            balanced = "󰾅";
            power-saver = "󰾆";
          };
        };

        cpu.format = "󰻠 {usage}%";
        memory.format = "󰍛 {percentage}%";

        # eno1 is the wired link, wlp9s0 the wireless one.
        network = {
          format-ethernet = "󰈀 {ifname}";
          format-wifi = "󰖩 {essid} {signalStrength}%";
          format-disconnected = "󰅛 offline";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        # Nothing binds the volume keys any more (see sway.nix), so this is
        # the only volume control.
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 muted";
          format-icons.default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        tray.spacing = 8;
      }
    ];

    # The @colors come from the catppuccin waybar stylesheet, which theme.nix
    # prepends to this one; @accent is the flavour accent (mauve).
    style = ''
      * {
        font-family: "${font.name}";
        font-size: ${toString font.sizePx}px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: @base;
        color: @text;
      }

      #workspaces button {
        padding: 0 8px;
        background: transparent;
        color: @overlay0;
      }

      #workspaces button:hover {
        background: @surface0;
        color: @text;
      }

      #workspaces button.focused {
        color: @accent;
        box-shadow: inset 0 -2px @accent;
      }

      #workspaces button.urgent {
        color: @red;
      }

      #window {
        color: @subtext0;
      }

      #clock,
      #cpu,
      #power-profiles-daemon,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #mode {
        padding: 0 10px;
      }

      #clock {
        color: @accent;
      }

      #cpu {
        color: @green;
      }

      #memory {
        color: @yellow;
      }

      #network {
        color: @blue;
      }

      #network.disconnected {
        color: @red;
      }

      #pulseaudio {
        color: @teal;
      }

      #pulseaudio.muted {
        color: @overlay0;
      }

      /* Balanced is the resting state, so it stays as quiet as the window
         title; the two ends of the range are the ones worth noticing. */
      #power-profiles-daemon {
        color: @subtext0;
      }

      #power-profiles-daemon.performance {
        color: @peach;
      }

      #power-profiles-daemon.power-saver {
        color: @green;
      }

      #mode {
        background: @surface0;
        color: @text;
      }
    '';
  };
}
