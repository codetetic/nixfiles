{
  config,
  lib,
  pkgs,
  ...
}:
let
  font = config.local.fonts.mono;

  # -f so swaylock forks once the screen is actually covered rather than
  # blocking until it is unlocked; swayidle is started with -w (home-manager's
  # default extraArgs) and would otherwise sit on the command for the whole
  # time the session is locked, never reaching the timeout below it.
  lock = "${lib.getExe' pkgs.swaylock "swaylock"} -f";

  # swaymsg ships in the compositor package, so this has to be the same one
  # programs.sway.package names in src/system/configuration.nix — it is already
  # in the system closure, and pkgs.sway would build a second compositor just
  # for its client. The unit below runs commands through sh with a PATH
  # containing only bash, so neither this nor powerprofilesctl can be spelled
  # bare.
  swaymsg = lib.getExe' pkgs.swayfx "swaymsg";

  # The same package services.power-profiles-daemon installs in
  # src/system/configuration.nix, which is also where the polkit rule letting
  # this run from outside a login session lives.
  powerprofilesctl = lib.getExe' pkgs.power-profiles-daemon "powerprofilesctl";
in
{
  programs.swaylock = {
    enable = true;

    # programs.sway.extraPackages already installs it system-wide, so this
    # module only writes ~/.config/swaylock/config — the same split as
    # wayland.windowManager.sway.package in sway.nix. Authentication works
    # because nixos' wayland-session module, which programs.sway pulls in,
    # declares security.pam.services.swaylock; a home-manager swaylock with no
    # PAM service could not unlock the session at all.
    package = null;

    # The colours are catppuccin's, opted into in theme.nix; everything here is
    # geometry and behaviour, which that theme does not set.
    settings = {
      font = font.name;
      # swaylock draws with cairo, so this is device pixels rather than points.
      font-size = font.sizePx;

      # Bigger than the 50px default: with no background image the ring is the
      # only thing on screen, and at the default size it reads as a stray dot.
      indicator-radius = 100;
      indicator-thickness = 8;

      # The theme colours the caps-lock states, which are inert unless the
      # indicator is told to show them.
      indicator-caps-lock = true;

      # Nothing typed cannot be a wrong password; without this, brushing enter
      # counts as an attempt and flashes the ring red.
      ignore-empty-password = true;
      show-failed-attempts = true;
    };

    # No `image`: wpaperd rotates the background every 30 minutes (see
    # wallpaper.nix) so there is no one file to point at, and swaylock's other
    # option — screenshotting the session — would leave whatever was on screen
    # legible behind the ring. It falls back to `color`, which the theme sets
    # to the same base the rest of the desktop sits on.
  };

  # Locks on its own; the manual route is Mod4+Escape, bound in sway.nix.
  services.swayidle = {
    enable = true;
    # sway-session.target rather than the wider graphical session, matching
    # autotiling in sway.nix.
    systemdTargets = [ "sway-session.target" ];

    timeouts = [
      {
        timeout = 300;
        command = lock;
      }
      {
        # Well after the lock, so the display only goes dark once the session is
        # already covered, and the machine drops to the eco profile at the same
        # point. DPMS is driven through the compositor because there is no X
        # server here to run xset against.
        #
        # This is as far as it goes: nothing here suspends or hibernates, so an
        # idle machine stays up and reachable over ssh and tailscale, just dark
        # and clocked down.
        timeout = 600;
        command = "${swaymsg} 'output * power off' && ${powerprofilesctl} set power-saver";
        # Back to power-profiles-daemon's own default rather than to whatever
        # was set before idling; a profile picked by hand does not survive the
        # round trip.
        resumeCommand = "${swaymsg} 'output * power on' && ${powerprofilesctl} set balanced";
      }
    ];

    events = {
      # loginctl lock-session, so anything that asks logind to lock the seat
      # gets the same screen as the timeout and the keybinding. There is no
      # before-sleep counterpart because this machine never sleeps.
      lock = lock;
    };
  };
}
