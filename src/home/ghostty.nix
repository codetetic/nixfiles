{ pkgs, ... }:
{
  programs.ghostty = {
    settings = {
      # Start fish directly rather than going through the bash-execs-fish hook
      # in the system config.
      command = "${pkgs.fish}/bin/fish --login";

      font-family = "FiraCode Nerd Font";
      font-size = 14;
    };
  };
}
