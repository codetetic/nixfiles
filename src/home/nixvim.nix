{
  config,
  inputs,
  pkgs,
  ...
}:
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
      # Follows theme.nix rather than repeating the flavour; there is no
      # catppuccin module for nixvim, so it sets its own colorscheme.
      settings.flavour = config.catppuccin.flavor;
      # No integrations block: catppuccin 2.0 turns neotree and blink_cmp on by
      # default, so both plugins below are themed without asking. (native_lsp
      # is gone in 2.0 — LSP highlights come from semantic tokens now.)
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

    # --- File explorer ---
    # neo-tree rather than nvim-tree: it is the closer match to VSCode's
    # explorer (git status in the gutter, follows the active file) and the one
    # catppuccin themes by default.
    plugins.neo-tree = {
      enable = true;

      settings = {
        # Quit rather than leave a lone sidebar sitting in an empty window,
        # which is what VSCode does when the last editor closes.
        close_if_last_window = true;

        window = {
          position = "left";
          width = 30;
        };

        filesystem = {
          # VSCode's "reveal active file" behaviour, on by default there.
          follow_current_file = {
            enabled = true;
            leave_dirs_open = true;
          };

          # Dotfiles are most of what this repo is; hiding them would hide the
          # flake. Gitignored files stay hidden, as in VSCode's default.
          filtered_items = {
            hide_dotfiles = false;
            hide_gitignored = true;
          };
        };
      };
    };

    # Open the sidebar at startup, as VSCode does. `show` rather than the bare
    # `Neotree` command so the cursor stays in the editor rather than landing
    # in the tree.
    #
    # The guard matters because nvim is defaultEditor here: git hands it commit
    # messages and rebase todos, and `nvim -d` is the merge tool. A sidebar has
    # no business in any of those, and VimEnter is late enough that filetype
    # detection has already run, so the buffer can be identified.
    autoCmd = [
      {
        event = [ "VimEnter" ];
        desc = "Open the file explorer, as VSCode does";
        callback.__raw = ''
          function()
            local skip = { gitcommit = true, gitrebase = true }
            if vim.o.diff or skip[vim.bo.filetype] then
              return
            end
            vim.cmd("Neotree show")
          end
        '';
      }
    ];

    # VSCode's explorer toggle and "focus explorer".
    keymaps = [
      {
        mode = "n";
        key = "<C-b>";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Toggle file explorer";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree focus<cr>";
        options.desc = "Focus file explorer";
      }
    ];

    # --- Nix language support ---
    # nvim-lspconfig is installed for its default configs only (cmd, filetypes,
    # root markers); the servers themselves are enabled through `lsp.servers`,
    # which is nixvim's newer module over neovim's built-in vim.lsp.
    plugins.lspconfig.enable = true;

    lsp.servers.nixd = {
      enable = true;
      # Same settings vscodium hands nixd, one level deeper: `config` here is
      # the vim.lsp.config table, and LSP settings live under its `settings`
      # key, which nixd namespaces by server name.
      config.settings.nixd = config.local.nixd.settings;
    };

    # blink-cmp rather than nvim-cmp: it needs no companion source plugins for
    # LSP, path and buffer, and catppuccin themes it out of the box.
    plugins.blink-cmp = {
      enable = true;

      settings = {
        # Tab cycles the menu and accepts, which is the VSCode reflex.
        keymap.preset = "super-tab";

        sources.default = [
          "lsp"
          "path"
          "buffer"
          "snippets"
        ];

        # VSCode shows the doc pane beside the list without being asked.
        completion.documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
        };

        # web-devicons above is the nerd-font build, so use the wider glyphs.
        appearance.nerd_font_variant = "normal";

        signature.enabled = true;
      };
    };
  };
}
