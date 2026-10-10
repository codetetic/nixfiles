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

  # Spotifast is not on Flathub and its release bundle is unsigned, so flatpak
  # verifies nothing when installing it. What upstream signs is checksums.txt
  # (raw Ed25519); the key below is assets/update-public-key.hex from its repo.
  spotifast-update = pkgs.writeShellApplication {
    name = "spotifast-update";
    runtimeInputs = with pkgs; [
      curl
      jq
      openssl
      xxd
      flatpak
    ];
    text = ''
      app=rocks.spotifast.Spotifast
      key=e44c87b1550484c687947bd927ae333ff431cc7adc6cc33533c628f82016b554
      releases=https://github.com/crmne/spotifast/releases

      tag=''${1:-$(curl -fsSL https://api.github.com/repos/crmne/spotifast/releases/latest | jq -r .tag_name)}
      bundle=spotifast-$tag-x86_64.flatpak

      installed=$(flatpak info --user "$app" 2>/dev/null | sed -n 's/^ *Version: //p' || true)
      if [ "v$installed" = "$tag" ]; then
        echo "spotifast $tag is already installed"
        exit 0
      fi

      dir=$(mktemp -d)
      trap 'rm -rf "$dir"' EXIT
      cd "$dir"
      for file in checksums.txt checksums.txt.sig "$bundle"; do
        curl -fL --progress-bar -O "$releases/download/$tag/$file"
      done

      # The prefix is the fixed DER header of an Ed25519 SubjectPublicKeyInfo.
      echo "302a300506032b6570032100$key" | xxd -r -p \
        | openssl pkey -pubin -inform DER -out key.pem
      openssl pkeyutl -verify -pubin -inkey key.pem -rawin \
        -in checksums.txt -sigfile checksums.txt.sig
      grep -F "  $bundle" checksums.txt | sha256sum -c -

      flatpak install --user --noninteractive --or-update --bundle "$bundle"
    '';
  };
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
    pkgs.krita

    pkgsWeekly.zoom-us

    pkgs.skills

    spotifast-update
  ];

  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.ssh.enable = true;
  programs.git.enable = true;
  programs.direnv.enable = true;
  programs.claude-code.enable = true;
  programs.claude-code.package = inputs.claude-code.packages.${system}.default;
  programs.nixvim.enable = true;
  # Off for now, while nvim is the editor. src/home/vscodium.nix keeps its
  # settings, and the sway assign for app_id "codium" still points at
  # workspace 3, so flipping this back is the only step to undo it.
  programs.vscodium.enable = false;
  programs.ghostty.enable = true;
  programs.imv.enable = true;
  wayland.windowManager.sway.enable = true;
  programs.discord.enable = true;
  programs.discord.package = pkgsWeekly.discord;
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
