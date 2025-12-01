{
  pkgs,
  user,
  ...
}:

{
  imports = [
    ../../home
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

    # Media
    gimp3

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
