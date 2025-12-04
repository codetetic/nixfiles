{
  user,
  ...
}:

{
  # Users
  users.users.${user.name} = {
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
  };

  # Virtualisation
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Programmes
  programs.steam = {
    enable = true;
  };
}
