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

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zsh-catppuccin = {
      url = "github:JannoTjarks/catppuccin-zsh";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      user = {
        name = "moobert";
        description = "Peter Measham";
        email = "github@codetetic.co.uk";
      };
      modules = [
        ./src/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user.name} = import ./src/home.nix;
          home-manager.extraSpecialArgs = { inherit inputs user; };
        }
      ];
    in
    {
      nixosConfigurations."odyssey" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs user; };
        modules = [
          ./src/system/odyssey.nix
        ]
        ++ modules;
      };
    };
}
