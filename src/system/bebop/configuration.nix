{
  user,
  pkgs,
  inputs,
  ...
}:

{
  # Programmes
  # gamescope, the SteamOS micro-compositor. A game runs in a nested wayland
  # session, so one that wants an exclusive fullscreen mode, a lower internal
  # resolution or a different refresh rate gets it inside that nest instead of
  # making sway retune DP-2 and reflow every other workspace. Put it in front
  # of a game with `gamescope -- %command%` in its Steam launch options, or as
  # the Lutris runner command.
  programs.gamescope = {
    enable = true;
    # Lets gamescope renice itself above the game it is hosting, which is what
    # keeps the compositor scheduled often enough to keep presenting frames
    # when the game saturates the CPU. It costs the plain systemPackages
    # install: with this set the module ships it through security.wrappers
    # instead, at /run/wrappers/bin/gamescope. Steam's FHS environment puts
    # that directory first on PATH, so launch options still find it.
    capSysNice = true;
  };

  programs.steam = {
    enable = true;
    # Proton builds only. This is STEAM_EXTRA_COMPAT_TOOLS_PATHS, which Steam
    # scans for compatibilitytool.vdf, so gamescope was never picked up from
    # here — it comes from programs.gamescope above.
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      inputs.dw-proton.packages.${pkgs.system}.default
    ];
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.yubikey-manager.enable = true;

  # Virtualisation
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    libvirtd.enable = true;
  };
  users.users.${user.name}.extraGroups = [
    "podman"
    "libvirtd"
    "plugdev"
  ];
  # Allow podman to use port 80
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  # Services
  services = {
    ratbagd.enable = true;
  };
}
