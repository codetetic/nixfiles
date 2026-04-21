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
    tmux
    gnumake
    podman-compose
    gnome-boxes
    wezterm
  ];

  catppuccin = {
    enable = true;
    nvim.enable = false;
    firefox.enable = false;
    chromium.enable = false;
    vivaldi.enable = false;
  };

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
