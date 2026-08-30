{
  description = "NixOS Systems";

  inputs = {
    nixpkgs = {
      url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-26.05-chilled/0.1";
    };

    # Fast-moving packages that we want fresher than the chilled channel.
    nixpkgs-weekly = {
      url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
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
      ...
    }:
    let
      system = "x86_64-linux";

      homeKey = builtins.readFile ./src/home.pub;

      # A separate nixpkgs instance needs its own config; nixpkgs.config from
      # the NixOS module system does not apply here.
      pkgsWeekly = import inputs.nixpkgs-weekly {
        inherit system;
        config.allowUnfree = true;
      };

      mkNixosConfig =
        { host, user }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs user pkgsWeekly; };
          modules = [
            ./src/system/hardware.nix
            ./src/system/${host}/hardware.nix
            ./src/system/configuration.nix
            ./src/system/${host}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user pkgsWeekly; };
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
