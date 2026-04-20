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

      # fzf theming (catppuccin mocha)
      set -gx FZF_DEFAULT_OPTS "\
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
        --height=40% --layout=reverse --border"
    '';
  };

  home.packages = with pkgs; [
    fzf
    grc
  ];
}
