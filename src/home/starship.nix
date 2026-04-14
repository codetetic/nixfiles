{ ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      git_branch = {
        truncation_length = 20;
        truncation_symbol = "…";
      };
      nodejs = {
        format = "[$symbol($version)]($style) ";
        version_format = "\${major}";
      };
      php = {
        format = "[$symbol($version)]($style) ";
        version_format = "\${major}.\${minor}";
      };
      nix_shell = {
        format = "[$symbol]($style)";
      };
    };
  };
}
