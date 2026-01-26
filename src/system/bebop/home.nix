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
    gamescope
    lutris
    openrct2
    openttd

    # Browsers
    vivaldi
    vivaldi-ffmpeg-codecs

    # Apps
    wezterm
    claude-code-bun
    gnome-boxes
    quickemu
    quickgui
  ];

  programs.zsh.enable = true;
  programs.ssh.enable = true;

  programs.chromium.enable = true;

  programs.git.enable = true;
  programs.direnv.enable = true;
  programs.nixvim.enable = true;
  programs.vscode.enable = true;

  programs.keychain = {
    enable = true;
    keys = [
      "home"
      "github"
    ];
  };
}
