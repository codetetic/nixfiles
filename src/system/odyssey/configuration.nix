{
  user,
  ...
}:

{
  # Virtualisation
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users.users.${user.name} = {
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
  };

  # Programmes
  programs.steam = {
    enable = true;
  };
}
