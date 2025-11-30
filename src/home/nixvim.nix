{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
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
    };

    # --- LSP and completion ---
    plugins = {
      lsp = {
        enable = true;
        servers.nixd.enable = true;
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };

      treesitter = {
        enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          nix
        ];
      };

      lualine = {
        enable = true;
      };

      web-devicons.enable = true;

      none-ls = {
        enable = true;
        sources.formatting.nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rfc-style;
        };
      };
    };
  };
}
