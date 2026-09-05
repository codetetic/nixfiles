{
  config,
  lib,
  osConfig,
  ...
}:
let
  # Same checkout the nr-* aliases in fish.nix drive. nixd resolves this at
  # request time with builtins.getFlake, so it must be the working tree, not a
  # store copy: a store path would freeze option completion at whatever the
  # last rebuild saw and never show an option added since.
  flake = "${config.home.homeDirectory}/Projects/nixfiles";
  host = osConfig.networking.hostName;
in
{
  # Shared nixd settings, so vscodium and nixvim can't drift apart — the same
  # reasoning as fonts.nix. Both editors run the same nixd binary from
  # development.nix; only the way they hand it settings differs.
  options.local.nixd.settings = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = ''
      Contents of nixd's `nixd` settings table, as its LSP clients pass it:
      {option}`programs.vscodium` under `nix.serverSettings.nixd`, nixvim under
      `lsp.servers.nixd.config.settings.nixd`. Do not set this.
    '';
  };

  # Unconfigured, nixd silently returns zero completion items — it knows the
  # language but not the package set or the option tree, so `pkgs.` and
  # `programs.` offer nothing and it reads as completion being broken rather
  # than unconfigured.
  config.local.nixd.settings = {
    # Read through the checkout's own flake rather than interpolating
    # pkgs.path: interpolating a path *copies* it, so that spelling duplicated
    # the entire nixpkgs source tree into the store under a second hash. This
    # form also means completion follows flake.lock, so nr-update moves it.
    nixpkgs.expr = "import (builtins.getFlake \"${flake}\").inputs.nixpkgs { }";

    options = {
      nixos.expr = "(builtins.getFlake \"${flake}\").nixosConfigurations.${host}.options";

      # home-manager is a NixOS module here, so its options hang off the system
      # config rather than a standalone flake output; getSubOptions unwraps the
      # per-user attrsOf submodule to the options themselves.
      home-manager.expr = "(builtins.getFlake \"${flake}\").nixosConfigurations.${host}.options.home-manager.users.type.getSubOptions []";
    };

    # nixd shells out for formatting; without a command, format-on-save and the
    # format action do nothing. Matches the flake's nix fmt.
    formatting.command = [ "nixfmt" ];
  };
}
