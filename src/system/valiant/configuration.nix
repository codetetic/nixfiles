{
  user,
  ...
}:

{
  # User
  users.users.${user.name} = {
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  # Virtualisation
  virtualisation = {
    docker.enable = true;
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Services
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  # Programmes
  programs.steam = {
    enable = true;
  };
}
