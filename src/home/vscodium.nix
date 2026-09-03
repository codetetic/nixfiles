{ config, pkgs, ... }:
let
  # VSCodium has no setting for the sidebar, tab or status bar font: that
  # chrome is fixed CSS, and window.zoomLevel is the only thing that scales
  # it, by 1.2^level across the whole window. Zooming in for the sidebar's
  # sake would drag the editor up with it, so the sizes below are divided
  # back down by the same factor to leave the editor and integrated terminal
  # where they were.
  zoomLevel = 1;
  zoomFactor = 1.2; # 1.2 ^ zoomLevel; update alongside zoomLevel.
  fontSize = builtins.floor (config.local.fonts.mono.sizePx / zoomFactor + 0.5);
in
{
  programs.vscodium = {
    profiles.default.extensions = with pkgs.vscode-extensions; [
      mkhl.direnv
      jnoortheen.nix-ide
      asvetliakov.vscode-neovim
      eamodio.gitlens
      nefrob.vscode-just-syntax
      shardulm94.trailing-spaces
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
    ];

    profiles.default.userSettings = {
      "update.mode" = "none";
      "window.zoomLevel" = zoomLevel;
      "editor.fontFamily" = config.local.fonts.mono.name;
      "editor.fontSize" = fontSize;
      "terminal.integrated.fontFamily" = config.local.fonts.mono.name;
      "terminal.integrated.fontSize" = fontSize;
      "chat.mcp.gallery.enabled" = false;
      "editor.minimap.enabled" = false;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "vscode-neovim.neovimClean" = true;
      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
      "chat.disableAIFeatures" = true;
      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = "catppuccin-mocha";
    };
  };
}
