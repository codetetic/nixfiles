{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  # Backs the wl-copy clipboard provider configured below.
  home.packages = [ pkgs.wl-clipboard ];

  programs.nixvim = {
    nixpkgs.source = inputs.nixpkgs;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # --- UI ---
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    colorscheme = "catppuccin";

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    opts = {
      number = true;
      hidden = true;
      mouse = "a";
      swapfile = false;
      undofile = true;
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
      termguicolors = true;
    };

    plugins.lualine = {
      enable = true;
    };
    plugins.web-devicons = {
      enable = true;
    };
  };
}
