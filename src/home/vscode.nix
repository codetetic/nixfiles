{ pkgs, ... }: {
  programs.vscode = {
    profiles.default.extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      mkhl.direnv
      jnoortheen.nix-ide
      asvetliakov.vscode-neovim
      eamodio.gitlens
      shardulm94.trailing-spaces
    ];

    profiles.default.userSettings = {
      "terminal.integrated.fontFamily" = "FiraCode Nerd Font";
      "terminal.integrated.fontSize" = 14;
      "chat.mcp.gallery.enabled" = false;
      "editor.minimap.enabled" = false;
      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = "catppuccin-mocha";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "vscode-neovim.neovimClean" = true;
      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
    };
  };
}
