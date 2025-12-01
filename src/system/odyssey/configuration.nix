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
      "podman"
    ];
  };

  # Programmes
  programs.steam = {
    enable = true;
  };
}
