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
    inputs.elysia.packages.${pkgs.system}.default

    # Apps
    wezterm
    gnome-boxes
    quickemu
    quickgui
  ];

  catppuccin = {
    enable = true;
    nvim.enable = false;
    vivaldi.enable = false;
  };

  programs.nix-your-shell = {
    enable = true;
    nix-output-monitor.enable = true;
  };

  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.vivaldi.enable = true;
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
