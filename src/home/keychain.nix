{ ... }: {
  programs.keychain = {
    enableZshIntegration = true;
    agents = [ "ssh" ];
    keys = [ "~/.ssh/codetetic" ];
  };
}
