{
  pkgs,
  ...
}:

{
  imports = [
    ./home
  ];

  home.stateVersion = "25.05";
  home.username = "moobert";
  home.homeDirectory = "/home/moobert";

  home.packages = with pkgs; [
    # Development
    git
    devenv
    nixd
    nixfmt-rfc-style
    pwgen
    silver-searcher
    btop
    fastfetch

    # Utilities
    tilix
    zoom-us
    discord
    vlc
    gimp3
    transmission_4-gtk

    # Games
    openrct2
    openttd
  ];

  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.git.enable = true;
  programs.ssh.enable = true;
  programs.keychain.enable = true;
  programs.direnv.enable = true;
  programs.nixvim.enable = true;
  programs.vscode.enable = true;

  programs.firefox.enable = true;
  programs.chromium.enable = true;

  programs.lutris.enable = true;
}
