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

    # Space, the de facto standard: every plugin README that writes `<leader>ff`
    # assumes it, and in normal mode space is only a synonym for `l`, so nothing
    # is lost. Must be set before any mapping is defined, which nixvim handles by
    # emitting globals at the top of init.lua.
    globals.mapleader = " ";

    # telescope shells out for these: ripgrep backs live_grep, fd backs
    # find_files. Neither is in home.packages, and nixvim's telescope module
    # only pulls in bat (for preview highlighting), so name them here rather
    # than let the pickers come up empty.
    extraPackages = with pkgs; [
      ripgrep
      fd
    ];

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

            # .git is the one dotfile there is never a reason to browse, and
            # showing dotfiles is what puts it there. never_show rather than
            # hide_by_name so it stays hidden when the H toggle reveals the
            # rest — the toggle is for finding a dotfile, not for spelunking
            # in the object store.
            never_show = [ ".git" ];
          };

          # Git colouring is on by default, but it only refreshes on writes
          # made from inside nvim (enable_refresh_on_write). OS-level watchers
          # instead, so a `git checkout` or an edit from another window shows
          # up without a manual R. Supersedes enable_refresh_on_write.
          use_libuv_file_watcher = true;
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

      # Hunk navigation and actions, under <leader>h as gitsigns' own README
      # has them. ]h/[h rather than the more usual ]c/[c: ]c is vim's builtin
      # "next diff change", and nvim is the merge tool here, so clobbering it
      # would cost more in a three-way merge than it gains in a normal buffer.
      # nav_hunk rather than next_hunk/prev_hunk, which gitsigns deprecated.
      {
        mode = "n";
        key = "]h";
        action = "<cmd>Gitsigns nav_hunk next<cr>";
        options.desc = "Next git hunk";
      }
      {
        mode = "n";
        key = "[h";
        action = "<cmd>Gitsigns nav_hunk prev<cr>";
        options.desc = "Previous git hunk";
      }
      {
        mode = "n";
        key = "<leader>hp";
        action = "<cmd>Gitsigns preview_hunk<cr>";
        options.desc = "Preview git hunk";
      }
      {
        mode = "n";
        key = "<leader>hs";
        action = "<cmd>Gitsigns stage_hunk<cr>";
        options.desc = "Stage git hunk";
      }
      {
        mode = "n";
        key = "<leader>hr";
        action = "<cmd>Gitsigns reset_hunk<cr>";
        options.desc = "Reset git hunk";
      }
      {
        mode = "n";
        key = "<leader>hb";
        action = "<cmd>Gitsigns blame_line<cr>";
        options.desc = "Blame line (full)";
      }
      {
        mode = "n";
        key = "<leader>hd";
        action = "<cmd>Gitsigns diffthis<cr>";
        options.desc = "Diff this file against the index";
      }
      {
        mode = "n";
        key = "<leader>ht";
        action = "<cmd>Gitsigns toggle_current_line_blame<cr>";
        options.desc = "Toggle inline blame";
      }
    ];

    # --- Syntax ---
    # A real parse tree per buffer instead of vim's regex syntax files, which is
    # what makes JSX/TSX and PHP interleaved with HTML come out right — both are
    # languages nested inside another one, and a line-at-a-time regex cannot see
    # where one ends. indent as well as highlight: the regex indenter has no
    # idea what to do inside a template literal or a chained arrow function.
    # Only the grammars listed below are affected; anything else keeps the old
    # syntax highlighting.
    plugins.treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;

      # An explicit list, because the default is *every* grammar nvim-treesitter
      # knows about — a few hundred megabytes of parsers for languages that will
      # never be opened here. Only the ones this config has a use for: the two
      # languages below, the markup they are embedded in, and nix, which is what
      # this repo is written in.
      #
      # php covers PHP interleaved with HTML (php_only is the variant for files
      # that are pure PHP); the jsdoc and phpdoc grammars are what highlight the
      # docblocks both languages lean on for types.
      grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
        php
        phpdoc
        javascript
        jsdoc
        typescript
        tsx
        html
        css
        json
        nix
      ];
    };

    # --- Language servers ---
    # nvim-lspconfig is installed for its default configs only (cmd, filetypes,
    # root markers); the servers themselves are enabled through `lsp.servers`,
    # which is nixvim's newer module over neovim's built-in vim.lsp. Each one
    # named here brings its own package in with it, so nothing needs adding to
    # extraPackages.
    plugins.lspconfig.enable = true;

    lsp.servers.nixd = {
      enable = true;
      # Same settings vscodium hands nixd, one level deeper: `config` here is
      # the vim.lsp.config table, and LSP settings live under its `settings`
      # key, which nixd namespaces by server name.
      config.settings.nixd = config.local.nixd.settings;
    };

    # PHP. phpactor rather than intelephense, which is the stronger of the two
    # on completion and stubs but is proprietary and has no package mapping in
    # nixvim — it would have to be pointed at pkgs.intelephense by hand and
    # allowed through as unfree. Swap the name here if that trade is worth it.
    lsp.servers.phpactor.enable = true;

    # JavaScript and TypeScript, one server for both plus JSX/TSX. ts_ls is
    # typescript-language-server, which carries its own tsserver, so a project
    # without typescript in its node_modules still gets completion and
    # diagnostics.
    lsp.servers.ts_ls.enable = true;

    # --- Git ---
    # The nearest thing to GitLens: gutter signs for added/changed/deleted
    # lines, inline blame on the cursor line, and stage/reset/preview per hunk.
    # catppuccin themes it by default.
    plugins.gitsigns = {
      enable = true;

      settings = {
        # GitLens' headline feature — who last touched this line, at the end of
        # it, greyed out. Off by default in gitsigns.
        current_line_blame = true;
        current_line_blame_opts = {
          virt_text = true;
          virt_text_pos = "eol";
          # Long enough not to flicker while moving through a file, short
          # enough to feel like it is just there.
          delay = 300;
        };
        current_line_blame_formatter = "  <author>, <author_time:%R> · <summary>";
      };
    };

    # --- Fuzzy finding ---
    plugins.telescope = {
      enable = true;

      # The native fzf sorter, a compiled C matcher in place of telescope's Lua
      # one. Worth having: the Lua sorter is the part that feels slow once a
      # picker is listing a whole nixpkgs checkout.
      extensions.fzf-native.enable = true;

      # <C-p> is VSCode's quick-open, kept here because the reflex transfers.
      # The rest follow telescope's own README so its docs match this config.
      keymaps = {
        "<C-p>" = {
          action = "find_files";
          options.desc = "Find files";
        };
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Find files";
        };
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Grep across the project";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Find open buffers";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Search help tags";
        };
        "<leader>fd" = {
          action = "diagnostics";
          options.desc = "Search diagnostics";
        };

        # GitLens' history views. git_bcommits is the one worth remembering:
        # the commits touching the current file, with a diff in the preview.
        "<leader>gc" = {
          action = "git_commits";
          options.desc = "Repository history";
        };
        "<leader>gf" = {
          action = "git_bcommits";
          options.desc = "History of this file";
        };
        "<leader>gs" = {
          action = "git_status";
          options.desc = "Changed files";
        };
      };
    };

    # blink-cmp rather than nvim-cmp: it needs no companion source plugins for
    # LSP, path and buffer, and catppuccin themes it out of the box.
    plugins.blink-cmp = {
      enable = true;

      settings = {
        # Tab cycles the menu and accepts, which is the VSCode reflex.
        keymap.preset = "super-tab";

        # Completion is only wanted in the languages actually worked on here,
        # so the menu stays out of the way in config files, commit messages and
        # scratch buffers. blink takes a predicate rather than a filetype list;
        # returning false just suppresses the menu, the plugin stays loaded.
        enabled = {
          __raw = ''
            function()
              return vim.tbl_contains(
                { "nix", "php", "javascript", "javascriptreact" },
                vim.bo.filetype
              )
            end
          '';
        };

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
