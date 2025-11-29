{
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./home
  ];

  home.stateVersion = "25.05";
  home.username = username;
  home.homeDirectory = "/home/${username}";

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

    # Comms
    zoom-us
    discord

    # KDE
    krita
    kdePackages.ktorrent

    # Media
    vlc

    # Games
    openrct2
    openttd
    heroic
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
