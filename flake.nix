{
  description = "NixOS Systems";

  inputs = {
    nixpkgs = {
      url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-26.05-chilled/0.1";
    };

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };

    dw-proton = {
      url = "github:imaviso/dwproton-flake";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nixpkgs-xr,
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
            home-manager.nixosModules.home-manager
            nixpkgs-xr.nixosModules.nixpkgs-xr
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user; };
              home-manager.users.${user.name} = {
                imports = [
                  ./src/system/${host}/home.nix
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
