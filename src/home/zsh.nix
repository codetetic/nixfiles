{ inputs, ... }:
{
  programs.zsh = {
    syntaxHighlighting.enable = true;

    shellAliases = {
      nr-update = "nix flake update --flake ~/src/nixfiles";
      nr-test = "sudo nixos-rebuild test --flake ~/src/nixfiles#$(hostname)";
      nr-switch = "sudo nixos-rebuild switch --flake ~/src/nixfiles#$(hostname)";
      nr-boot = "sudo nixos-rebuild boot --flake ~/src/nixfiles#$(hostname)";
    };
  };
}
