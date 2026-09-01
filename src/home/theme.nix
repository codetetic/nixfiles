{ ... }:
{
  catppuccin = {
    flavor = "mocha";
    accent = "mauve";

    enable = false;

    ghostty.enable = true;
    rofi.enable = true;
    sway.enable = true;
    waybar.enable = true;

    # Must be vscode, not vscodium: the module declares a catppuccin.vscodium
    # option but its config reads catppuccin.vscode.profiles for every
    # supported editor, so the vscodium one is inert.
    vscode.profiles.default = {
      enable = true;
      icons.enable = true;
    };
  };
}
