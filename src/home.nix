{
  pkgs,
  user,
  ...
}:

{
  imports = [
    ./home
  ];

  home.stateVersion = "25.05";
  home.username = user.name;
  home.homeDirectory = "/home/${user.name}";

  home.packages = with pkgs; [
    # Utilities
    btop
    ncdu
    pwgen
    fastfetch

    # Development
    git
    silver-searcher
    devenv
    nixd
    nixfmt-rfc-style

    # Chat
    zoom-us
    discord

    # Media
    vlc
    gimp3
    transmission_4-gtk

    # Windows
    bottles
    wine
    winetricks

    # Games
    openrct2
    openttd
  ];

  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.git.enable = true;
  programs.keychain.enable = true;
  programs.direnv.enable = true;
  programs.nixvim.enable = true;
  programs.vscode.enable = true;

  programs.firefox.enable = true;
  programs.chromium.enable = true;
}
