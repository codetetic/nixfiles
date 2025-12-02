{ user, ... }:
{
  programs.git = {
    settings = {
      user.name = user.description;
      user.email = user.email;
      init.defaultBranch = "main";
      alias = {
        st = "status";
        ci = "commit";
        co = "checkout";
        br = "branch";
      };
    };
  };
}
