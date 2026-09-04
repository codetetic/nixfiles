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
  programs.imv.enable = true;
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

      # imv-dir.desktop rather than imv.desktop: given a single file it runs
      # `imv -n <file> <dirname>`, so opening one image from thunar loads the
      # whole folder and the arrow keys walk it. imv.desktop would open that
      # one file and nothing else.
      "image/png" = "imv-dir.desktop";
      "image/jpeg" = "imv-dir.desktop";
      "image/gif" = "imv-dir.desktop";
      "image/webp" = "imv-dir.desktop";
      "image/tiff" = "imv-dir.desktop";
      "image/bmp" = "imv-dir.desktop";
      "image/avif" = "imv-dir.desktop";
      "image/heif" = "imv-dir.desktop";
      "image/jxl" = "imv-dir.desktop";
      "image/svg+xml" = "imv-dir.desktop";
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
