{ config, pkgs, ... }: {
  programs.vscodium = {
    profiles.default.extensions = with pkgs.vscode-extensions; [
      mkhl.direnv
      jnoortheen.nix-ide
      asvetliakov.vscode-neovim
      eamodio.gitlens
      shardulm94.trailing-spaces
    ];

    profiles.default.userSettings = {
      "update.mode" = "none";
      "editor.fontFamily" = config.local.fonts.mono.name;
      "editor.fontSize" = config.local.fonts.mono.sizePx;
      "terminal.integrated.fontFamily" = config.local.fonts.mono.name;
      "terminal.integrated.fontSize" = config.local.fonts.mono.sizePx;
      "chat.mcp.gallery.enabled" = false;
      "editor.minimap.enabled" = false;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "vscode-neovim.neovimClean" = true;
      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
      "chat.disableAIFeatures" = true;
    };
  };
}
