{
  config,
  osConfig,
  pkgs,
  ...
}:
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

  # Same checkout the nr-* aliases in fish.nix drive. nixd resolves this at
  # request time with builtins.getFlake, so it must be the working tree, not a
  # store copy: a store path would freeze option completion at whatever the
  # last rebuild saw and never show an option added since.
  flake = "${config.home.homeDirectory}/Projects/nixfiles";
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

      # Without this nixd has nothing to complete against and silently returns
      # zero items — it knows the language, but not the package set or the
      # option tree, so `pkgs.` and `programs.` offer nothing and it reads as
      # completion being broken rather than unconfigured.
      "nix.serverSettings".nixd = {
        # pkgs.path rather than a getFlake on the checkout: this is the same
        # pinned nixpkgs the config is built from, already realised in the
        # store, so completion does not re-lock the flake on every request.
        nixpkgs.expr = "import ${pkgs.path} { }";

        options = {
          nixos.expr = "(builtins.getFlake \"${flake}\").nixosConfigurations.${osConfig.networking.hostName}.options";

          # home-manager is a NixOS module here, so its options hang off the
          # system config rather than a standalone flake output; getSubOptions
          # unwraps the per-user attrsOf submodule to the options themselves.
          home-manager.expr = "(builtins.getFlake \"${flake}\").nixosConfigurations.${osConfig.networking.hostName}.options.home-manager.users.type.getSubOptions []";
        };

        # nixd shells out for formatting; without a command, format-on-save and
        # the format action do nothing. Matches the flake's nix fmt.
        formatting.command = [ "nixfmt" ];
      };
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
