{ ... }:

{
  programs.ssh = {
    enableDefaultConfig = false;
    matchBlocks."ssh.dev.azure.com" = {
      hostname = "ssh.dev.azure.com";
      extraOptions = {
        WarnWeakCrypto = "yes";
      };
    };
  };
}
