{
  lib,
  pkgs,
  ...
}:

let
  ripwire = pkgs.callPackage ../pkgs/ripwire.nix { };

  # The key is read at launch from a file outside the store, which is
  # world-readable; the sandbox cannot read ~/.config, the server can.
  context7 = pkgs.writeShellScript "context7-mcp" ''
    export CONTEXT7_API_KEY="$(< "$HOME/.config/context7/api-key")"
    exec ${lib.getExe pkgs.context7-mcp} "$@"
  '';
in
{
  home.packages = [ ripwire ];

  programs.claude-code.mcpServers.ripwire = {
    command = lib.getExe ripwire;
    args = [ "--mcp" ];
  };

  programs.claude-code.mcpServers.context7.command = "${context7}";
}
