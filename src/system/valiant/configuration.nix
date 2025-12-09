{
  user,
  ...
}:

{
  # System
  system.autoUpgrade = {
    enable = false;
  };

  # Virtualisation
  virtualisation = {
    docker.enable = true;
  };
  users.users.${user.name}.extraGroups = [ "docker" ];
}
