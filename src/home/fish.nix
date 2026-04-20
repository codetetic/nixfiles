{ pkgs, ... }:
{
  programs.fish = {
    shellAliases = {
      nr-update = "nix flake update --flake ~/src/nixfiles";
      nr-test = "sudo nixos-rebuild test --flake ~/src/nixfiles#$(hostname)";
      nr-switch = "sudo nixos-rebuild switch --flake ~/src/nixfiles#$(hostname)";
      nr-boot = "sudo nixos-rebuild boot --flake ~/src/nixfiles#$(hostname)";
    };

    plugins = [
      { name = "bass"; src = pkgs.fishPlugins.bass.src; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      { name = "sponge"; src = pkgs.fishPlugins.sponge.src; }
    ];

    interactiveShellInit = ''
      set -g fish_greeting  # disable welcome message
      set -gx EDITOR nvim
    '';
  };

  home.packages = with pkgs; [
    fzf
    grc
  ];
}
