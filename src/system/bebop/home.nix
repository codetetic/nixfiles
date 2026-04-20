{
  inputs,
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
    gnumake

    # Games
    gamescope
    lutris
    openrct2
    openttd
    inputs.elysia.packages.${pkgs.system}.default

    # Browsers
    vivaldi
    vivaldi-ffmpeg-codecs

    # Apps
    wezterm
    gnome-boxes
    quickemu
    quickgui
    cosign
    piper
  ];

  catppuccin.enable = true;

  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;

  programs.chromium.enable = true;

  programs.ssh.enable = true;
  programs.git.enable = true;
  programs.direnv.enable = true;
  programs.nixvim.enable = true;
  programs.vscode.enable = true;

  programs.keychain = {
    enable = true;
    keys = [
      "home"
      "github"
      "azure"
    ];
  };
}
