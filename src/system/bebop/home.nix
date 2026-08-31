{
  inputs,
  pkgs,
  pkgsWeekly,
  user,
  config,
  ...
}:

{
  imports = [
    ../../home
  ];

  home.stateVersion = "25.05";
  home.username = user.name;
  home.homeDirectory = "/home/${user.name}";

  home.packages = [
    inputs.helium.packages.${pkgs.system}.default

    pkgs.zoom-us
    (pkgs.spotify-player.override { withNotify = false; })

    pkgsWeekly.claude-code
    pkgs.skills
  ];

  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.ssh.enable = true;
  programs.git.enable = true;
  programs.direnv.enable = true;
  programs.nixvim.enable = true;
  programs.vscodium.enable = true;
  programs.ghostty.enable = true;
  wayland.windowManager.sway.enable = true;
  programs.discord.enable = true;
  programs.firefox.enable = true;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
  programs.rofi.enable = true;
  programs.waybar.enable = true;
  services.wpaperd.enable = true;

  # Helium handles web links. claude-code-url-handler.desktop is not installed
  # by nix (Claude Code drops it in ~/.local/share/applications), but the
  # association has to be listed here or it is lost when nix owns this file.
  home.sessionVariables.BROWSER = "helium";
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium.desktop";
      "application/xhtml+xml" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "x-scheme-handler/about" = "helium.desktop";
      "x-scheme-handler/unknown" = "helium.desktop";
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    };
  };

  services.spotifyd = {
    enable = true;
  };

  xdg.configFile."spotify-player/app.toml".text = ''
    enable_media_control = false
  '';

  programs.keychain = {
    enable = true;
    keys = [
      "home"
      "github-codetetic"
      "github-moobert"
      "azure"
    ];
  };

  programs.lutris = {
    enable = true;
    protonPackages = [
      pkgs.proton-ge-bin
      inputs.dw-proton.packages.${pkgs.system}.default
    ];
    extraPackages = with pkgs; [
      umu-launcher
      winetricks
    ];
  };
}
