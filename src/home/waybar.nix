{ config, lib, ... }:
let
  font = config.local.fonts.mono;
  cpuTemperature = config.local.waybar.cpuTemperature;
  hasTemperature = cpuTemperature.hwmonPath != null;
in
{
  # Which hwmon device carries the CPU sensor is a property of the board, so
  # the path is declared in src/system/bebop/home.nix rather than here. Left
  # unset, the module is dropped from the bar rather than reading whatever
  # thermal zone 0 happens to be.
  options.local.waybar.cpuTemperature = {
    hwmonPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
      description = ''
        Absolute path to the *device's* `hwmon` directory — the one that
        contains `hwmonN`, not `hwmonN` itself. waybar resolves the numbered
        directory inside it at startup, which is what keeps this working
        across a boot that renumbers the hwmon devices.
      '';
    };

    inputFilename = lib.mkOption {
      type = lib.types.str;
      default = "temp1_input";
      description = "Sensor file to read inside {option}`hwmonPath`.";
    };
  };

  # Replaces sway's built-in swaybar, which sway.nix now disables.
  config.programs.waybar = {
    # Started by sway-session.target rather than by sway's `bar` command.
    systemd.enable = true;

    settings = [
      (
        {
          layer = "top";
          position = "top";
          height = 30;

          modules-left = [
            "sway/workspaces"
            "sway/mode"
            "sway/scratchpad"
          ];
          modules-center = [ "sway/window" ];
          modules-right = [
            "pulseaudio"
            "bluetooth"
            "idle_inhibitor"
            "power-profiles-daemon"
          ]
          ++ lib.optional hasTemperature "temperature"
          ++ [
            "cpu"
            "memory"
            "network"
            "tray"
            "clock"
          ];

          "sway/workspaces".disable-scroll = true;
          "sway/mode".format = "<span style=\"italic\">{}</span>";
          "sway/window".max-length = 80;

          # The scratchpad is the only place a window gets hidden here — the
          # space bindings in sway.nix moved it there and sway's own minus
          # bindings were dropped — and sway gives no sign at all that something
          # is in it. show-empty keeps this invisible until it holds something,
          # so the usual state of the bar is unchanged.
          "sway/scratchpad" = {
            format = "{icon} {count}";
            format-icons = [
              "󱊔"
              "󱊖"
            ];
            show-empty = false;
            tooltip = true;
            tooltip-format = "{app}: {title}";
          };

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

          # blueman's applet already sits in the tray (see bluetooth.nix); this
          # is the state at a glance rather than another menu — how many devices
          # are connected, and whether the adapter is even on. Click opens the
          # same manager window the applet's menu does.
          bluetooth = {
            format-on = "󰂯";
            format-off = "󰂲";
            format-connected = "󰂱 {num_connections}";
            # Nothing to say when there is no adapter at all; an empty format
            # leaves no label, and waybar hides a module with no label.
            format-disabled = "";
            format-no-controller = "";
            tooltip-format = "{controller_alias}";
            tooltip-format-connected = "{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}";
            on-click = "blueman-manager";
          };

          # swayidle locks after 5 minutes and blanks after 10 (see
          # swaylock.nix). Sway inhibits that on its own for a fullscreen video,
          # but not for one in a tiled window, which is exactly when the screen
          # going dark is most annoying. Click to hold it awake, click again to
          # let go — the icon shows the state, not the action.
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "󰈈";
              deactivated = "󰈉";
            };
            tooltip-format-activated = "Idle inhibited — the screen stays on";
            tooltip-format-deactivated = "Idle timers running";
          };

          tray.spacing = 8;
        }
        // lib.optionalAttrs hasTemperature {
          # Tctl on this board, which is the sensor the CPU's own boost
          # behaviour is keyed off, so it is the number worth watching. 85 is
          # where the class changes to critical; the chip itself throttles well
          # above that.
          temperature = {
            hwmon-path-abs = cpuTemperature.hwmonPath;
            input-filename = cpuTemperature.inputFilename;
            interval = 5;
            format = "󰔏 {temperatureC}°C";
            critical-threshold = 85;
          };
        }
      )
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
      #bluetooth,
      #idle_inhibitor,
      #temperature,
      #scratchpad,
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

      /* Only ever visible when something is hidden in there, so it is worth
         noticing rather than blending in with the workspace numbers. */
      #scratchpad {
        color: @peach;
      }

      #bluetooth {
        color: @blue;
      }

      #bluetooth.connected {
        color: @accent;
      }

      /* Deactivated is the resting state and says nothing; lit means the idle
         timers are being held off, which is worth seeing. */
      #idle_inhibitor {
        color: @overlay0;
      }

      #idle_inhibitor.activated {
        color: @yellow;
      }

      #temperature {
        color: @maroon;
      }

      #temperature.critical {
        color: @red;
      }
    '';
  };
}
