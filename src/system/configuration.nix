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
    enable = true;
    flake = "/home/${user.name}/src/nixfiles#${config.networking.hostName}";
    flags = [
      "--update-input" "nixpkgs"
      "--commit-lock-file"
    ];
    dates = "daily";
    randomizedDelaySec = "30min";
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
    cosmic-greeter.enable = true;
  };
  services.desktopManager = {
    cosmic.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    # Emoji
    noto-fonts-color-emoji

    # Code + icons
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg

    # High-quality Japanese fonts
    source-han-sans
    source-han-serif
  ];

  # DNS
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = 53;
        http = 4000;
      };
      bootstrapDns = {
        upstream = "tcp+udp:1.1.1.1";
        ips = [ "1.1.1.1" ];
      };
      upstreams = {
        strategy = "strict";
        groups.default = [
          "https://1.1.1.1/dns-query"
          "tcp+udp:1.1.1.1"
        ];
      };
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
      blocking = {
        denylists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          ];
        };
        clientGroupsBlock = {
          default = [
            "ads"
          ];
        };
      };
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

  # Networking
  environment.systemPackages = with pkgs; [
    networkmanager-openvpn
    wireguard-tools
  ];
  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    nameservers = [ "127.0.0.1" ];
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Services
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
