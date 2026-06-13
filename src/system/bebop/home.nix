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

  home.packages = [
    inputs.helium.packages.${pkgs.system}.default

    pkgs.zoom-us
    (pkgs.spotify-player.override { withNotify = false; })

    pkgs.claude-code
  ];

  catppuccin = {
    enable = true;
    nvim.enable = false;
  };

  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.ssh.enable = true;
  programs.git.enable = true;
  programs.direnv.enable = true;
  programs.nixvim.enable = true;
  programs.vscodium.enable = true;
  programs.ghostty.enable = true;
  programs.discord.enable = true;

  services.spotifyd = {
    enable = true;
  };

  xdg.configFile."spotify-player/app.toml".text = ''
    enable_media_control = false
  '';

  programs.keychain = {
    enable = true;
    keys = [
      "home"
      "github-codetetic"
      "github-moobert"
      "azure"
    ];
  };
}
