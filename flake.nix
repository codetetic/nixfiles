{
  description = "NixOS Systems";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-26.05";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dw-proton = {
      url = "github:Momoyaan/dwproton-flake";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-flatpak,
      catppuccin,
      ...
    }:
    let
      system = "x86_64-linux";

      homeKey = builtins.readFile ./src/home.pub;

      mkNixosConfig =
        { host, user }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs user; };
          modules = [
            ./src/system/hardware.nix
            ./src/system/${host}/hardware.nix
            ./src/system/configuration.nix
            ./src/system/${host}/configuration.nix
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            nix-flatpak.nixosModules.nix-flatpak
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user; };
              home-manager.users.${user.name} = {
                imports = [
                  ./src/system/${host}/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
            }
          ];
        };
    in
    {
      nixosConfigurations."bebop" = mkNixosConfig {
        host = "bebop";
        user = {
          name = "moobert";
          description = "Peter Measham";
          email = "github@codetetic.co.uk";
          keys = [ homeKey ];
        };
      };
    };
}
