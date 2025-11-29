{ ... }: {
  programs.bash = {
    shellAliases = {
      nr-update = "nix flake update --flake ~/src/nixfiles";
      nr-test = "sudo nixos-rebuild test --flake ~/src/nixfiles";
      nr-switch = "sudo nixos-rebuild switch --flake ~/src/nixfiles";
    };
  };
}
