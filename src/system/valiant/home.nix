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
    yarn
    nodejs_22
    php82
    php82Packages.composer
    tmux
    symfony-cli
    azure-cli
    claude-code-bun
    gnumake
    podman-compose
    gnome-boxes
    wezterm
    piper
  ];

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
