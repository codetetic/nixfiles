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
    nixpkgs = {
      source = inputs.nixpkgs;
      # Setting `source` makes nixvim import its own nixpkgs rather than reusing
      # the one home-manager already built, and `nixpkgs.config` from the module
      # system does not reach that instance — the same trap `pkgsWeekly` has in
      # flake.nix. Without this, barbar refuses to evaluate: its licence is the
      # JSON one ("shall be used for Good, not Evil"), which nixpkgs classes as
      # unfree. Mirrors `nixpkgs.config.allowUnfree` in configuration.nix rather
      # than introducing a new policy.
      config.allowUnfree = true;
    };

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

    # The toolchain rust_analyzer needs (see lsp.servers.rust_analyzer below).
    # extraPackagesAfter, not extraPackages: nixvim wraps nvim with --suffix
    # PATH for this list and --prefix for the other, so a project that pins its
    # own rustc through direnv still wins and this is only the fallback for a
    # crate opened outside one.
    extraPackagesAfter = with pkgs; [
      cargo
      rustc
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

      # Routes the built-in `gq` motion through conform, which is the one thing
      # a format keybinding cannot do: format a *range*. Neovim only installs
      # its own LSP formatexpr when the buffer's is still at the default, so
      # setting it here means conform wins even in buffers with a server
      # attached — which is what the lsp_format fallback below is for.
      formatexpr = "v:lua.require'conform'.formatexpr()";
    };

    plugins.lualine = {
      enable = true;
    };
    plugins.web-devicons = {
      enable = true;
    };

    # --- Editor tabs ---
    # `hidden = true` above lets buffers accumulate with no visual trace, so the
    # only way to know what is open is <leader>fb. VSCode answers that with a
    # tab bar, and barbar is the closest match: reorderable, clickable, with
    # diagnostics and git status on the tab itself.
    #
    # barbar rather than bufferline because catppuccin ships an integration for
    # barbar and not for bufferline (CLAUDE.md, "Prefer apps that theme
    # consistently") — catppuccin 2.0 auto-detects it, so nothing needs adding
    # to theme.nix.
    plugins.barbar = {
      enable = true;

      settings = {
        # A lone buffer needs no tab bar, and a lone buffer is exactly what nvim
        # is opened with as $EDITOR — commit messages, rebase todos. Same reason
        # neo-tree no longer opens at startup.
        auto_hide = 1;

        # The toggleterm split is a panel, not a file. Without this it takes a
        # tab of its own and the count stops meaning "files I have open".
        exclude_ft = [ "toggleterm" ];

        # Shifts the tab bar right by the width of the tree instead of drawing
        # it underneath — the offset VSCode has between explorer and tabs. The
        # event is what barbar watches to drop the offset again when the tree
        # closes.
        sidebar_filetypes."neo-tree".event = "BufWipeout";

        # VSCode puts an error count on the tab. Warnings too would be noisy on
        # a narrow tab, and gitsigns' +/~/- markers are on by default already.
        icons.diagnostics."vim.diagnostic.severity.ERROR".enabled = true;
      };

      # VSCode's own tab bindings, which all survive the trip: Alt+<n> jumps to
      # the nth tab, Alt+0 to the last, Ctrl+PageUp/Down cycles, adding Shift
      # drags the tab instead. Closing is the one that cannot come across —
      # Ctrl+w is vim's window prefix — so it goes under the leader with the
      # other buffer commands.
      keymaps = {
        previous.key = "<C-PageUp>";
        next.key = "<C-PageDown>";
        movePrevious.key = "<C-S-PageUp>";
        moveNext.key = "<C-S-PageDown>";
        goTo1.key = "<A-1>";
        goTo2.key = "<A-2>";
        goTo3.key = "<A-3>";
        goTo4.key = "<A-4>";
        goTo5.key = "<A-5>";
        goTo6.key = "<A-6>";
        goTo7.key = "<A-7>";
        goTo8.key = "<A-8>";
        goTo9.key = "<A-9>";
        last.key = "<A-0>";
        close.key = "<leader>bd";
        # barbar's own idea, with no VSCode counterpart: label every tab with a
        # letter and jump by typing it. Worth a binding once there are more
        # tabs open than Alt+<n> reaches.
        pick.key = "<leader>bb";
      };
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

    # The sidebar starts closed — nvim is defaultEditor here, so it is just as
    # often opened on a commit message or as `nvim -d` for a merge, where a
    # file tree is only noise. <C-b> is VSCode's own explorer toggle, so the
    # reflex to summon it transfers.
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
      # toggleterm's own <C-`> below only arrives over the kitty keyboard
      # protocol. ghostty speaks it, the linux VT does not, so keep a plain
      # ASCII way in for the times nvim is not running under ghostty.
      {
        mode = "n";
        key = "<leader>t";
        action = "<cmd>ToggleTerm<cr>";
        options.desc = "Toggle terminal";
      }
      # VSCode's Shift+Alt+F, which needs no keyboard protocol to arrive — a
      # terminal sends it as plain ESC-prefixed `F`. Visual mode as well as
      # normal: conform formats just the selection when called from there.
      {
        mode = [
          "n"
          "v"
        ];
        key = "<A-F>";
        action = "<cmd>lua require('conform').format({ async = true })<cr>";
        options.desc = "Format buffer or selection";
      }
    ];

    # --- Terminal ---
    # VSCode's panel: a shell at the bottom of the window, on the same toggle
    # key, rather than dropping the editor for a full-screen :terminal.
    plugins.toggleterm = {
      enable = true;

      settings = {
        # Ctrl+` is VSCode's binding. It is only representable at all because
        # both ends speak the kitty keyboard protocol (ghostty since 1.0, nvim
        # since 0.10) — a legacy terminal cannot distinguish it from a bare
        # backtick, which is what <leader>t above is there for.
        #
        # Deliberately *not* toggleterm's own suggested <C-\>: that key is the
        # prefix of the built-in <C-\><C-n>, the only way out of terminal mode,
        # and mapping it alone in terminal mode shadows the escape hatch.
        open_mapping = "[[<C-`>]]";

        direction = "horizontal";
        size = 15;

        # nvim's :terminal runs $SHELL, and the account's shell is still bash —
        # fish is reached by ghostty launching it directly (see ghostty.nix),
        # not by a passwd entry. Name fish here too, so the panel is the same
        # shell as every other window, aliases and prompt included.
        shell = "${pkgs.fish}/bin/fish";

        # Come back in insert mode rather than wherever the cursor was left.
        # Toggling away mid-command and returning to a dead normal-mode cursor
        # is the one place toggleterm does not behave like VSCode's panel.
        persist_mode = false;
      };
    };

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
        rust
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

    # Rust. `lsp.servers` brings rust-analyzer itself, but not the toolchain it
    # drives: rust-analyzer shells out to `cargo metadata` to discover a crate's
    # layout and to `cargo check` for diagnostics, so without cargo and rustc on
    # PATH it attaches and then reports nothing. The old plugins.lsp module had
    # installCargo/installRustc options for this; the newer `lsp.servers` one
    # does not, so they are named in extraPackagesAfter below.
    lsp.servers.rust_analyzer.enable = true;

    # --- Formatting ---
    # On a key, never on save. This repo is committed by hand, so a formatter
    # that rewrites the buffer on every `:w` turns a stray save into a diff;
    # `format_on_save` and `format_after_save` are both deliberately unset.
    #
    # conform rather than the LSP's own formatting: nixfmt and prettier are not
    # reachable through nixd or ts_ls, and php_cs_fixer is not phpactor's job
    # either. lsp_format = "fallback" still hands anything with no formatter
    # listed below to whichever server is attached.
    plugins.conform-nvim = {
      enable = true;

      # Resolves each formatter name below to its nixpkgs package and adds it to
      # extraPackages, so the list here is the only place they are named.
      autoInstall.enable = true;

      settings = {
        default_format_opts.lsp_format = "fallback";

        formatters_by_ft = {
          # The same formatter `nix fmt` runs through nixfmt-tree, so formatting
          # from inside the editor and from the shell cannot disagree.
          nix = [ "nixfmt" ];

          php = [ "php_cs_fixer" ];

          # rustfmt, not the LSP: rust-analyzer's own formatting request just
          # proxies to rustfmt anyway, and going direct means it still works in
          # a buffer the server has not attached to.
          rust = [ "rustfmt" ];

          javascript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          html = [ "prettier" ];
          css = [ "prettier" ];
          json = [ "prettier" ];
          markdown = [ "prettier" ];

          # Filetypes with nothing else configured: strip trailing whitespace
          # and no more. Safe everywhere, including the commit messages and
          # scratch buffers where a real formatter has no business running.
          "_" = [ "trim_whitespace" ];
        };
      };
    };

    # --- Git ---
    # Display only: gutter signs for added/changed/deleted lines and inline
    # blame on the cursor line. Gitsigns' hunk actions (stage, reset, preview)
    # and its navigation are deliberately unbound — staging and committing
    # happen in a terminal, and the only in-editor git wanted here is being
    # able to see what changed and read the history. The :Gitsigns commands
    # are all still there for a one-off. catppuccin themes it by default.
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
        # Nothing toggles this any more, so it is on for every buffer; set
        # current_line_blame above to false to be rid of it.
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
                { "nix", "php", "javascript", "javascriptreact", "rust" },
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
