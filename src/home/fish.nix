{ pkgs, ... }:
{
  programs.fish = {
    shellAliases = {
      nr-check = "nix flake check ~/Projects/nixfiles";
      nr-update = "nix flake update --flake ~/Projects/nixfiles";
      nr-test = "sudo nixos-rebuild test --flake ~/Projects/nixfiles#$(hostname)";
      nr-switch = "sudo nixos-rebuild switch --flake ~/Projects/nixfiles#$(hostname)";
      nr-boot = "sudo nixos-rebuild boot --flake ~/Projects/nixfiles#$(hostname)";
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

  # Enabled for FZF_DEFAULT_OPTS, which is where catppuccin.fzf puts its
  # colors (see theme.nix); without this the theme evaluates but is never
  # emitted. Fish integration stays off because the fzf-fish plugin above
  # already owns the key bindings, ctrl-r included. This also installs fzf,
  # so it is no longer listed below.
  programs.fzf = {
    enable = true;
    enableFishIntegration = false;
  };

  home.packages = with pkgs; [
    grc
  ];
}
