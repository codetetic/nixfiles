{ config, pkgs, ... }:
{
  programs.ghostty = {
    settings = {
      # Start fish directly rather than going through the bash-execs-fish hook
      # in the system config.
      command = "${pkgs.fish}/bin/fish --login";

      font-family = config.local.fonts.mono.name;
      font-size = config.local.fonts.mono.size;
    };
  };
}
