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

        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio" "cpu" "memory" "network" "tray" "clock" ];

        "sway/workspaces".disable-scroll = true;
        "sway/mode".format = "<span style=\"italic\">{}</span>";
        "sway/window".max-length = 80;

        # Same format and once-a-second tick as the old `date` statusCommand.
        clock = {
          interval = 1;
          format = "{:%Y-%m-%d %X}";
          tooltip-format = "<tt>{calendar}</tt>";
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
          format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
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
        font-size: ${toString font.size}px;
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

      #mode {
        background: @surface0;
        color: @text;
      }
    '';
  };
}
