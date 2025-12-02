{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  # https://github.com/JMartJonesy/kickstart.nixvim
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
      termguicolors = true;
    };

    plugins.lualine = {
      enable = true;
    };
    plugins.web-devicons = {
      enable = true;
    };

    # Inserts matching pairs of parens, brackets, etc.
    # https://nix-community.github.io/nixvim/plugins/nvim-autopairs/index.html
    plugins.nvim-autopairs = {
      enable = true;
    };

    # Autocompletion
    # See `:help cmp`
    # https://nix-community.github.io/nixvim/plugins/cmp/index.html
    plugins.blink-cmp = {
      enable = true;

      settings = {
        keymap = {
          preset = "default";
        };
      };
    };

    # https://nix-community.github.io/nixvim/plugins/lsp/index.html
    plugins.lsp = {
      enable = true;
      servers = {
        nixd = {
          enable = true;
        };
      };
    };

    # Highlight todo, notes, etc in comments
    # https://nix-community.github.io/nixvim/plugins/todo-comments/index.html
    plugins.todo-comments = {
      enable = true;
      settings = {
        signs = true;
      };
    };

    # Highlight, edit, and navigate code
    # https://nix-community.github.io/nixvim/plugins/treesitter/index.html
    plugins.treesitter = {
      enable = true;

      # Installing tree-sitter grammars from Nixpkgs (recommended)
      # https://nix-community.github.io/nixvim/plugins/treesitter/index.html#installing-tree-sitter-grammars-from-nixpkgs
      # grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        # Linux
        bash
        # Nix, Nixvim
        nix
        query # treesitter queries
      ];
    };

    plugins.none-ls = {
      enable = true;
      sources.formatting.nixfmt = {
        enable = true;
        package = pkgs.nixfmt-rfc-style;
      };
    };
  };
}
