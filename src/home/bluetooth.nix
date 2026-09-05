{
  lib,
  osConfig,
  ...
}:
# hardware.bluetooth is a NixOS option and lives in src/system/bebop/hardware.nix,
# so a host without a bluetooth adapter gets none of this.
lib.mkIf osConfig.hardware.bluetooth.enable {
  # bluez brings the stack up but ships no interface beyond bluetoothctl, so
  # pairing a headset meant a terminal and a scan. blueman is the GTK 3 front
  # end for it — which also means gtk.nix themes it, unlike most bluetooth
  # managers.
  #
  # The applet is the part that matters: it registers the bluetooth *agent*,
  # which is what answers a device's pairing request and shows the PIN. Without
  # one running, a device trying to pair is simply ignored. It also puts an
  # icon in waybar's tray (blueman-manager, the full window, is reachable from
  # its menu), and sends connect/disconnect notifications through mako.
  services.blueman-applet = {
    enable = true;
    # sway-session.target rather than the default graphical-session.target, to
    # track the compositor the way autotiling and swayidle do. The unit also
    # Requires tray.target, which is what pulls waybar up before it.
    systemdTargets = [ "sway-session.target" ];
  };
}
