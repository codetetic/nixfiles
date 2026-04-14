{ ... }:
{
  programs.bash = {
    historySize = 50000;
    historyFileSize = 50000;
    historyControl = [
      "ignoredups"
      "ignorespace"
      "erasedups"
    ];

    shellOptions = [
      "histappend" # append to history, don't overwrite
      "autocd" # `foo` instead of `cd foo`
      "cdspell" # fix minor cd typos
      "dirspell" # fix typos during tab completion
      "globstar" # ** recursive glob
      "checkwinsize" # update LINES/COLUMNS after each command
      "extglob" # extended globbing
      "nocaseglob" # case-insensitive globbing
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    shellAliases = {
      nr-update = "nix flake update --flake ~/src/nixfiles";
      nr-test = "sudo nixos-rebuild test --flake ~/src/nixfiles#$(hostname)";
      nr-switch = "sudo nixos-rebuild switch --flake ~/src/nixfiles#$(hostname)";
      nr-boot = "sudo nixos-rebuild boot --flake ~/src/nixfiles#$(hostname)";
    };

    initExtra = ''
      # Prefix history search on Up/Down
      bind '"\e[A": history-search-backward'
      bind '"\e[B": history-search-forward'

      # Ensure emacs-style line editing
      set -o emacs
    '';
  };
}
