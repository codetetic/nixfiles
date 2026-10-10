{
  lib,
  pkgs,
  ...
}:

let
  ripwire = pkgs.callPackage ../pkgs/ripwire.nix { };
in
{
  home.packages = [ ripwire ];

  programs.claude-code.mcpServers.ripwire = {
    command = lib.getExe ripwire;
    args = [ "--mcp" ];
  };
}
