{
  pkgs,
  user,
  ...
}:

{
  # Nix
  system.stateVersion = "25.05";
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

  # Virtualisation
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Fonts
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    # Code + icons
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg

    # High-quality Japanese fonts
    source-han-sans
    source-han-seri
  ];

  # Users
  users.users.${user.name} = {
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    isNormalUser = true;
    description = user.description;
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
  };

  # Programmes
  programs.nix-ld = {
    enable = true;
  };

  programs.steam = {
    enable = true;
  };
}
