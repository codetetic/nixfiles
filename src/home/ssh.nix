{ ... }:

{
  programs.ssh = {
    enableDefaultConfig = false;
    # TODO: fix
    matchBlocks."ssh.dev.azure.com" = {
      hostname = "ssh.dev.azure.com";
      extraOptions = {
        WarnWeakCrypto = "yes";
      };
    };
  };
}
