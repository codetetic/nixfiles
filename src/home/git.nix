{ ... }: {
  programs.git = {
    userName = "Peter Measham";
    userEmail = "github@codetetic.co.uk";

    aliases = {
      st = "status";
      ci = "commit";
      co = "checkout";
      br = "branch";
    };
  };
}
