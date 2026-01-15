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
  system.autoUpgrade = {
    flake = "/home/${user.name}/src/nixfiles#${config.networking.hostName}";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
    dates = "daily";
    persistent = true;
  };

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
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Desktop Environment
  services.xserver = {
    enable = true;
    xkb = {
      layout = "gb";
      variant = "";
    };
  };
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = user.name;
    };
    cosmic-greeter = {
      enable = true;
    };
  };
  services.desktopManager = {
    cosmic = {
      enable = true;
    };
  };
  services.system76-scheduler = {
    enable = true;
  };

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
      serif = [ "Noto Serif" "Source Han Serif" "DejaVu Serif" ];
      sansSerif = [ "Noto Sans" "Source Han Sans" "DejaVu Sans" ];
      monospace = [ "FiraCode Nerd Font" "DejaVu Sans Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Users
  users.users.${user.name} = {
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
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
    networkmanager-openvpn
    wireguard-tools
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

  security.polkit.enable = true;
}
