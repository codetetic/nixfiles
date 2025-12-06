{
  user,
  ...
}:

{
  # Virtualisation
  virtualisation = {
    docker.enable = true;
  };
  users.users.${user.name}.extraGroups = [ "docker" ];

  # Programmes
  programs.steam = {
    enable = true;
  };
}
