{
  inputs,
  pkgs,
  pkgsWeekly,
  user,
  config,
  ...
}:

let
  # pkgs.system is a deprecated alias in nixpkgs now and warns on every
  # evaluation; this is what it resolves to. Needed because flake inputs index
  # their packages by system.
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [
    ../../home
  ];

  home.stateVersion = "25.05";
  home.username = user.name;
  home.homeDirectory = "/home/${user.name}";

  home.packages = [
    inputs.helium.packages.${system}.default

    pkgs.zoom-us

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
  # Off for now, while nvim is the editor. src/home/vscodium.nix keeps its
  # settings, and the sway assign for app_id "codium" still points at
  # workspace 3, so flipping this back is the only step to undo it.
  programs.vscodium.enable = false;
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

  # k10temp's Tctl, on the CPU's SMBus function — the sensor waybar's
  # temperature module reads (see src/home/waybar.nix, which leaves the module
  # out of the bar entirely if this is unset). The PCI address is fixed for
  # this board; the hwmonN directory under it is not, which is why this stops
  # at `hwmon`.
  local.waybar.cpuTemperature.hwmonPath = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";

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
      inputs.dw-proton.packages.${system}.default
    ];
    extraPackages = with pkgs; [
      umu-launcher
      winetricks
    ];
  };
}
