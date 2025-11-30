{ user, ... }:
{
  programs.git = {
    settings = {
      user.name = user.description;
      user.email = user.email;
      aliases = {
        st = "status";
        ci = "commit";
        co = "checkout";
        br = "branch";
      };
    };
  };
}
