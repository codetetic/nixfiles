{ ... }:
{
  # thunar-volman only mounts removable media while thunar itself is running,
  # so a USB stick plugged in with no file manager open did nothing at all.
  # udiskie is the daemon half of that: it watches udisks2 (enabled in
  # src/system/configuration.nix, which this needs) and mounts on insert
  # whether or not anything is open.
  services.udiskie = {
    enable = true;
    automount = true;
    # Through mako, so a mount that happens with no window open still says
    # where it landed.
    notify = true;
    # Only while something is actually mounted — the tray is for unmounting
    # safely, and an icon that is there permanently to say "no devices" is
    # noise. This is also the whole reason the unit wants tray.target, and so
    # waybar, up first.
    tray = "auto";

    settings.program_options = {
      # The tray menu's "open" action, and the notification's. Left to itself
      # udiskie calls xdg-open, which has no default for inode/directory in
      # xdg.mimeApps (see src/system/bebop/home.nix) and picks whatever it
      # finds first. A bare name rather than a store path deliberately: the
      # thunar worth launching is the wrapper programs.thunar builds with the
      # archive and volman plugins in it, and pkgs.xfce.thunar would pull a
      # second, plugin-less copy into the home closure.
      file_manager = "thunar";
    };
  };
}
