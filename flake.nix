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

      homeKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvqYOiulexoYG0eg+Co5NggVoN3rfNECQ6fEu+wGvrj peter@codetetic.co.uk";

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
              home-manager.users.${user.name} = import ./src/system/${host}/home.nix;
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
