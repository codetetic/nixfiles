{
  description = "NixOS Systems";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    zsh-catppuccin = {
      url = "github:JannoTjarks/catppuccin-zsh";
      flake = false;
    };

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      cosmic-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      homeKey = builtins.readFile ./src/home.pub;

      users = {
        home = {
          name = "moobert";
          description = "Peter Measham";
          email = "github@codetetic.co.uk";
          keys = [ homeKey ];
        };
        work = {
          name = "peter";
          description = "Peter Measham";
          email = "github@codetetic.co.uk";
          keys = [ homeKey ];
        };
      };

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
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs user; };
              home-manager.users.${user.name} = {
                imports = [
                  ./src/system/${host}/home.nix
                  cosmic-manager.homeManagerModules.cosmic-manager
                ];
              };
            }
          ];
        };
    in
    {
      nixosConfigurations."odyssey" = mkNixosConfig {
        host = "odyssey";
        user = users.home;
      };
      nixosConfigurations."valiant" = mkNixosConfig {
        host = "valiant";
        user = users.work;
      };
    };
}
