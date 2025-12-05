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
