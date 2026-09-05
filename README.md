# nixfiles

Personal NixOS flake. One host: `bebop` — AMD desktop, ZFS root, SwayFX on Wayland,
Catppuccin Mocha throughout. See [CLAUDE.md](CLAUDE.md) for the architecture.

```
nr-check    # nix flake check
nr-update   # nix flake update
nr-test     # nixos-rebuild test   (this boot only)
nr-switch   # nixos-rebuild switch
nr-boot     # nixos-rebuild boot   (next boot)
```

Home-manager is a NixOS module here, so `nr-switch` rebuilds the user config too —
there is no separate `home-manager switch`.

---

# Sway cheatsheet

`Mod` is the Super/Windows key. Config: [`src/home/sway.nix`](src/home/sway.nix).

Tiling is automatic — [autotiling-rs](https://github.com/ammgws/autotiling-rs) picks the
split axis (longest side) before each new window, so there is nothing to split by hand.

### Launching and windows

| Key | Action |
| --- | --- |
| `Mod+Return` | Terminal (ghostty) |
| `Mod+d` | App launcher (`rofi -show drun`) |
| `Mod+BackSpace` | Browser (helium) |
| `Mod+Shift+q` | Close focused window |
| `Mod+f` | Fullscreen toggle |
| `Mod+a` | Focus parent container |
| `Mod+Escape` | Lock now (`swaylock -f`) |

### Focus and move

| Key | Action |
| --- | --- |
| `Mod+h/j/k/l` or `Mod+←↓↑→` | Move focus |
| `Mod+Shift+h/j/k/l` or `Mod+Shift+←↓↑→` | Move the window |
| `Mod+drag` (left button) | Move a floating window |
| `Mod+drag` (right button) | Resize a floating window |

### Workspaces

| Key | Action |
| --- | --- |
| `Mod+1`…`Mod+0` | Switch to workspace 1–10 |
| `Mod+Shift+1`…`Mod+Shift+0` | Move window to workspace 1–10 |
| `Mod+Tab` | Next workspace |
| `Mod+Shift+Tab` | Previous workspace |

Windows are auto-assigned: **3** = VSCodium (`codium`), **9** = Discord.
Sway starts focused on workspace 1.

### Scratchpad

| Key | Action |
| --- | --- |
| `Mod+Shift+space` | Send window to the scratchpad |
| `Mod+space` | Show / cycle scratchpad windows |

These replace sway's `Mod+minus` / `Mod+Shift+minus`, which are unbound here.

### Screenshots

| Key | Action |
| --- | --- |
| `Print` | Select a region, then annotate |
| `Shift+Print` | Whole screen, then annotate |

Both open [swappy](https://github.com/jtheoof/swappy) for annotation: draw, arrow, text,
blur, then `Ctrl+s` to save or `Ctrl+c` to copy. Nothing is written unless you save.
`Escape` during the region select cancels without opening anything.
Saves land in `~/Pictures/Screenshots/`. Configured in
[`src/home/screenshot.nix`](src/home/screenshot.nix).

### Resize mode

| Key | Action |
| --- | --- |
| `Mod+r` | Enter resize mode |
| `h/j/k/l` or `←↓↑→` | Grow / shrink |
| `Return` or `Escape` | Leave resize mode |

### Session

| Key | Action |
| --- | --- |
| `Mod+Shift+c` | Reload the sway config |
| `Mod+Shift+e` | Exit sway (confirmation prompt) |

Exiting sway drops back to the tuigreet login prompt on VT1, not to a dead console.

### Unbound on purpose

Layout switching is gone — `Mod+b`, `Mod+v` (split), `Mod+s` (stacking), `Mod+w` (tabbed)
and `Mod+e` (layout toggle) are all `null`. Tabbed and stacking always draw a titlebar that
`default_border pixel` cannot suppress, and autotiling makes the split bindings redundant.

### Idle behaviour

The screen locks after 5 minutes; after 10 the outputs power off and the machine drops to
the `power-saver` profile. It never suspends, so it stays reachable over ssh/tailscale.
Moving the mouse powers the outputs back on and restores `balanced`.
Configured in [`src/home/swaylock.nix`](src/home/swaylock.nix).

### Tray

waybar's tray holds two user services, both started with the sway session:

- **blueman-applet** — bluetooth. It registers the pairing agent, so a device asking to pair
  gets a prompt instead of silence; its menu opens blueman-manager for the full window.
  [`src/home/bluetooth.nix`](src/home/bluetooth.nix)
- **udiskie** — mounts removable media on insert whether or not thunar is open, notifies
  through mako, and its icon (visible only while something is mounted) is where to unmount
  safely. Opens mounts in thunar. [`src/home/udiskie.nix`](src/home/udiskie.nix)

### Theming

Catppuccin Mocha/mauve reaches each toolkit by a different route, so a palette change is
an edit in each: [`theme.nix`](src/home/theme.nix) opts individual programs in,
[`gtk.nix`](src/home/gtk.nix) themes GTK 3 (thunar) via a third-party port — upstream's is
archived — [`qt.nix`](src/home/qt.nix) themes Qt via qt5ct/qt6ct and Kvantum, and
[`flatpak.nix`](src/home/flatpak.nix) exports both into `~/.local/share` with a flatpak
override so sandboxed apps can read them. The NixOS side
([`configuration.nix`](src/system/configuration.nix)) separately colours the tuigreet
prompt.

---

# Neovim cheatsheet

Built with [nixvim](https://github.com/nix-community/nixvim); config lives in
[`src/home/nixvim.nix`](src/home/nixvim.nix). `vi`, `vim` and `nvim` all point at it, and it
is `$EDITOR`. **Leader is `<Space>`.** Clipboard is the Wayland system clipboard
(`unnamedplus` via `wl-copy`), so `y` and `p` share with every other app.

Defaults worth knowing: line numbers on, 4-space expandtab, no swapfile, persistent undo
(undo survives closing the file), mouse enabled in all modes.

### File explorer (neo-tree)

Opens on the left at startup — except in `git commit` / `git rebase` buffers and `nvim -d`.

| Key | Action |
| --- | --- |
| `Ctrl+b` | Toggle the explorer |
| `<leader>e` | Focus the explorer |

Inside the tree: `?` for the full help, `a` add, `d` delete, `r` rename, `c` copy, `x` cut,
`p` paste, `H` toggle hidden files, `R` refresh, `Enter` open, `S`/`s` open in a horizontal /
vertical split.

Dotfiles are shown (this repo is mostly dotfiles), gitignored files and `.git` are not.
The tree follows the active file and refreshes from OS file watchers, so a `git checkout`
in another window shows up without pressing `R`.

### Fuzzy finding (telescope)

| Key | Action |
| --- | --- |
| `Ctrl+p` | Find files (VSCode quick-open) |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep across the project |
| `<leader>fb` | Open buffers |
| `<leader>fh` | Help tags |
| `<leader>fd` | Diagnostics |

Inside a picker: `Ctrl+n`/`Ctrl+p` move, `Ctrl+u`/`Ctrl+d` scroll the preview,
`Ctrl+x`/`Ctrl+v`/`Ctrl+t` open in split/vsplit/tab, `Tab` multi-select,
`Esc` (or `Ctrl+c` from insert) close.

Backed by `ripgrep` and `fd`, with the native fzf sorter compiled in.

### Git

Display only. Gitsigns puts added/changed/deleted marks in the gutter and shows inline
blame — author, relative time, commit summary — at the end of the cursor line. There are no
hunk keybindings: staging, resetting and committing happen in a terminal. The `:Gitsigns`
commands still exist for a one-off, and `:Gitsigns toggle_current_line_blame` turns the
blame text off for the session.

History is through telescope:

| Key | Action |
| --- | --- |
| `<leader>gc` | Repository history |
| `<leader>gf` | History of the current file |
| `<leader>gs` | Changed files |

### LSP

Servers: `nixd` (Nix), `phpactor` (PHP), `ts_ls` (JS/TS/JSX/TSX). These are Neovim's
built-in LSP mappings — they are active in any buffer with a server attached.

| Key | Action |
| --- | --- |
| `K` | Hover documentation |
| `grn` | Rename symbol |
| `gra` | Code action |
| `grr` | References |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `gd` | Go to definition |
| `gO` | Document symbols |
| `Ctrl+s` (insert) | Signature help |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>fd` | All diagnostics in telescope |

### Completion (blink-cmp)

Deliberately limited to `nix`, `php`, `javascript` and `javascriptreact`, so the menu stays
out of the way in config files, commit messages and scratch buffers.

| Key | Action |
| --- | --- |
| `Tab` | Next item / accept |
| `Shift+Tab` | Previous item |
| `Ctrl+space` | Open the menu / toggle docs |
| `Ctrl+e` | Dismiss |

Sources are LSP, path, buffer and snippets. The documentation pane opens on its own after
200ms, and signature help shows while typing arguments.

### Syntax

Treesitter handles highlighting and indentation for the grammars actually used here: PHP
(+ phpdoc), JavaScript (+ jsdoc), TypeScript, TSX, HTML, CSS, JSON and Nix. Everything else
falls back to vim's regex syntax files.
