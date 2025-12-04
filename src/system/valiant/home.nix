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
    # Development
    nodejs_22
    php82
    tmux

    # Utilities
    keepassxc
    gnumake

    # Media
    gimp3

    # Games
    openrct2
    openttd
  ];

  programs.zsh.enable = true;

  programs.git.enable = true;
  programs.direnv.enable = true;
  programs.nixvim.enable = true;
  programs.vscode.enable = true;

  programs.librewolf.enable = true;
  programs.chromium.enable = true;

  programs.keychain = {
    enable = true;
    keys = [
      "home"
      "github"
      "azure"
    ];
  };
}
