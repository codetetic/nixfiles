{
  user,
  pkgs,
  inputs,
  ...
}:

let
  # Not pkgs.system: that alias is deprecated in nixpkgs and warns on every
  # evaluation. Same binding as in home.nix next door.
  inherit (pkgs.stdenv.hostPlatform) system;

  # Proton Experimental plus the RTSP patchset, for VRChat. World video
  # players go through Media Foundation, and neither stock Proton nor
  # GE-Proton can open an rtsp:// / rtspt:// source — which is what VRCDN and
  # most DJ worlds hand out as their low-latency stream, so the screen sits on
  # "Loading" while everyone else hears the set. Not in nixpkgs; it ships the
  # same tarball layout as GE-Proton, so this reuses that derivation and swaps
  # the source. steamDisplayName also replaces the tool's internal name in
  # compatibilitytool.vdf, which is the key Steam stores the per-game choice
  # under: pinning it means a version bump here does not unset the tool on
  # VRChat. Bump version and hash together, from
  # https://github.com/SpookySkeletons/proton-rtsp/releases
  proton-rtsp = (pkgs.proton-ge-bin.override { steamDisplayName = "Proton-RTSP"; }).overrideAttrs (
    finalAttrs: _: {
      pname = "proton-rtsp-bin";
      version = "proton-rtsp-11.0-20260609-4";
      src = pkgs.fetchzip {
        url = "https://github.com/SpookySkeletons/proton-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
        hash = "sha256-ENLAPkz6PhqBpGibwjnWJE8NEnUnmoM81IuPQB9Ufoc=";
      };
    }
  );
in
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
      inputs.dw-proton.packages.${system}.default
      proton-rtsp
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

    # The system half of blueman: the D-Bus service the applet talks to, plus
    # the polkit rules that let a normal user power the adapter and pair a
    # device without a password prompt. The applet itself is a user service,
    # in src/home/bluetooth.nix; it is useless without this. Sits here rather
    # than in the shared module because the adapter is declared next door in
    # hardware.nix.
    blueman.enable = true;
  };
}
