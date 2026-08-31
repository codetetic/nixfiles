{
  lib,
  pkgs,
  user,
  config,
  ...
}:

{
  # System
  system.stateVersion = "25.05";

  # Nix
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Locale
  time.timeZone = "Europe/London";
  console.keyMap = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # make pipewire realtime-capable
  security.rtkit.enable = true;

  # Desktop Environment
  services.xserver = {
    enable = true;
    xkb = {
      layout = "gb";
      variant = "";
    };
  };

  # GNOME
  services.displayManager.gdm.enable = true;
  # Force sway as the login session; GDM's chooser wasn't offering it.
  services.displayManager.defaultSession = "sway";
  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    simple-scan
    decibels
    showtime
    gnome-music
    totem
    gnome-tour
    gnome-shell-extensions
  ];

  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # needed for GTK apps launched from sway
    xwayland.enable = true;
    # Trimmed default list; pactl is used by the volume keys. The terminal,
    # launcher and other config dependencies live in src/home/sway.nix.
    extraPackages = with pkgs; [
      pulseaudio
      swayidle
      swaylock
    ];
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Set here rather than only in the shells: sway is started without sourcing
  # ~/.profile, so anything launched from the session (vscodium and its
  # integrated terminals included) would otherwise have no EDITOR and fall
  # back to nano/vi.
  environment.sessionVariables.EDITOR = "nvim";
  environment.sessionVariables.VISUAL = "nvim";

  # Fonts
  fonts.packages = with pkgs; [
    # Core, widely expected fonts
    dejavu_fonts

    # Modern, wide Unicode coverage
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # Code + icons
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg

    # High-quality East Asian fonts
    source-han-sans
    source-han-serif
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [
        "Noto Serif"
        "Source Han Serif"
        "DejaVu Serif"
      ];
      sansSerif = [
        "Noto Sans"
        "Source Han Sans"
        "DejaVu Sans"
      ];
      monospace = [
        "FiraCode Nerd Font"
        "DejaVu Sans Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Users
  users.users.${user.name} = {
    isNormalUser = true;
    description = user.description;
    openssh.authorizedKeys.keys = user.keys;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    (aspellWithDicts (
      dicts: with dicts; [
        en
        en-computers
        en-science
      ]
    ))
  ];

  # Networking
  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };

  # Firewall
  networking.nftables = {
    enable = true;
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  # Services
  services.tailscale = {
    enable = true;
  };
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Programmes
  programs.nix-ld = {
    enable = true;
  };
}
