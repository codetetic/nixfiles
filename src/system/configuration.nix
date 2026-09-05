{
  lib,
  pkgs,
  user,
  config,
  ...
}:

let
  # Pinned and fetched at build time rather than downloaded by the unit below.
  # A .flatpakrepo carries both the repo URL and its signing key, so adding the
  # remote from this file needs no network at runtime, which is what keeps the
  # unit from having to pull in and wait on network-online.target every boot.
  flathubRepo = pkgs.fetchurl {
    url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    hash = "sha256-M3HdJQ5h2eFjNjAHP+/aFTzUQm9y9K+gwzc64uj+oDo=";
  };
in
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

  # Login
  # greetd owns the login: it runs on VT1, authenticates over PAM and launches
  # sway directly. tuigreet is only the frontend that draws the prompt on the
  # console, so there is no X server and no GTK stack behind it, which is the
  # whole reason it replaced GDM. The layout at the prompt comes from
  # console.keyMap above and sway sets its own once it starts (see
  # input."type:keyboard" in src/home/sway.nix), so services.xserver went with
  # GNOME rather than being kept for the keymap.
  #
  # initial_session fires once, at boot, with no prompt: this machine goes
  # straight into sway. default_session is what greetd falls back to
  # afterwards, so exiting sway lands on tuigreet rather than silently
  # re-entering a second passwordless session.
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "sway";
        user = user.name;
      };
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd sway";
        user = "greeter";
      };
    };
  };

  # tuigreet draws with the console's 16 colours, so this is what themes the
  # login prompt; there is no catppuccin module for greetd itself. The palette
  # is repeated here rather than read from src/home/theme.nix because that one
  # is home-manager's, and these are NixOS options.
  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
    tty.enable = true;
  };

  # GDM unlocked the keyring as part of signing in. greetd has to be told to,
  # or it stays locked and vscodium prompts for a password the first time it
  # reaches for a secret. That only covers the tuigreet path: the autologin
  # above never sees a password, so on a normal boot the keyring stays locked
  # until something first asks for it.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # programs.sway already turns on security.polkit, but that is only the
  # daemon; the dialog that asks for the password was GNOME Shell's. soteria is
  # that agent without a desktop environment attached. Its module starts it
  # from graphical-session.target, which sway-session.target pulls in.
  security.soteria.enable = true;

  # File manager. Thunar is standalone by design, so unlike nautilus it does
  # not drag a desktop environment in behind it. gvfs gives it trash and
  # removable-media mounting, tumbler the thumbnails; xfconf, where it keeps
  # its settings, is switched on by the module itself.
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # The mounting backend itself. gvfs talks to it for thunar's own mounting,
  # and services.udiskie in src/home/udiskie.nix is what mounts a stick plugged
  # in while thunar is closed — that module is inert without this, as udisks2
  # is where the D-Bus interface it watches comes from.
  services.udisks2.enable = true;

  # home-manager's gtk module mirrors the theme, icon and cursor names it
  # writes to gtk-3.0/settings.ini into org/gnome/desktop/interface, and its
  # activation step needs the system dconf service to be there to load them.
  # A desktop environment would have switched this on; nothing here does.
  programs.dconf.enable = true;

  # Power. amd-pstate-epp is the scaling driver on this hardware, so the
  # profiles map onto the CPU's energy-performance preference rather than only
  # to a governor. swayidle drops the machine to power-saver once the screen
  # goes dark and puts it back on balanced on wake (see src/home/swaylock.nix);
  # powerprofilesctl is also how to switch by hand.
  services.power-profiles-daemon.enable = true;

  # switch-profile is allow_active in the shipped policy, which means a process
  # belonging to a logind session. swayidle is a systemd --user service, and
  # those live under user@.service rather than in the session, so polkit sees
  # no session, falls through to allow_any = no, and the idle profile switch
  # fails — or worse, pops a soteria password dialog at the lock screen. This
  # grants that one action to the one user who owns the seat.
  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (
        action.id == "org.freedesktop.UPower.PowerProfiles.switch-profile" &&
        subject.user == "${user.name}"
      ) {
        return polkit.Result.YES;
      }
    });
  '';

  # Sway
  programs.sway = {
    enable = true;
    # SwayFX is a drop-in fork of sway; it is only here for the rounded corners
    # configured in src/home/sway.nix. Swap back to pkgs.sway to drop them.
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true; # needed for GTK apps launched from sway
    xwayland.enable = true;
    # Trimmed default list; pactl backs waybar's volume module. The terminal,
    # launcher and other config dependencies live in src/home/sway.nix.
    extraPackages = with pkgs; [
      pulseaudio
      swayidle
      swaylock
    ];
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # xdg-open, for the callers that cannot see this machine's desktop files:
  # a flatpak sees only its own /usr/share/applications, and an electron app
  # ships its own opener that scans for a browser rather than asking. With
  # this, both go through the portal's OpenURI instead, which resolves the
  # handler on the host — so xdg.mimeApps in src/system/bebop/home.nix is
  # honoured and a link opens in helium rather than whatever was found first.
  # The gtk portal backend, which programs.sway already installs, is what
  # implements OpenURI.
  xdg.portal.xdgOpenUsePortal = true;

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

  # Flatpak, for apps that are not in nixpkgs or that upstream only ships
  # sandboxed. The module brings the daemon, the polkit rules and the flatpak
  # user, puts both exports directories on the profile path so installed apps
  # show up in rofi, and turns on fonts.fontDir so the sandbox can see the host
  # fonts configured above. It asserts xdg.portal.enable, which programs.sway
  # already satisfies with the gtk and wlr backends.
  services.flatpak.enable = true;

  # The module deliberately adds no remotes and flatpak is inert without one.
  # Running as root, remote-add writes to the system installation under
  # /var/lib/flatpak, which is the exports directory the module put on the
  # profile path. --if-not-exists leaves a remote edited by hand alone, so this
  # only ever does something on the first boot after switching.
  systemd.services.flatpak-flathub = {
    description = "Add the Flathub remote to the system flatpak installation";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${lib.getExe pkgs.flatpak} remote-add --if-not-exists flathub ${flathubRepo}
    '';
  };

  # Programmes
  programs.nix-ld = {
    enable = true;
  };
}
