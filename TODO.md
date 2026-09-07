# Sway setup — things still to add

Notes to self on gaps in the sway desktop. The numbered list is empty — what is
left is either deliberately not wanted or too small to rank.

Done and removed from this list: GTK theming (`src/home/gtk.nix`), Qt theming
(`src/home/qt.nix`, Kvantum), lock and idle (`src/home/swaylock.nix`), flatpak
theming (`src/home/flatpak.nix`), screenshots (`src/home/screenshot.nix`),
bluetooth (`src/home/bluetooth.nix`), automount (`src/home/udiskie.nix`),
waybar modules and the mako bindings (`src/home/waybar.nix`, `src/home/sway.nix`).

---

## 1 When Claude edits files it seems to touch and delete the following

        .bash_profile
        .bashrc
        .claude/agents
        .claude/commands
        .claude/hooks
        .claude/launch.json
        .claude/loop.md
        .claude/output-styles
        .claude/routines
        .claude/scheduled_tasks.json
        .claude/settings.json
        .claude/workflows
        .gitconfig
        .gitmodules
        .idea
        .mcp.json
        .profile
        .ripgreprc
        .vscode
        .zprofile
        .zshrc

## 2 Make yubikey work with lock screen

## Decided against

- **Clipboard history** (`cliphist` + rofi) — not wanted. wl-clipboard stays, as neovim's
  clipboard provider; nothing records what passes through it.
- **A waybar `disk` module** — statvfs on a ZFS dataset reports the pool's free space
  rather than a filesystem's, and snapshots and reservations make that number mean
  something different from what the bar would imply. `zpool list` is the honest answer.
- **Volume, media and brightness keys** — the waybar pulseaudio widget is enough, so the
  `XF86*` keys are deliberately left unbound and there is no `swayosd`.

---

## Smaller / lower priority

- **`kanshi`** for output profiles — only matters if a second display ever
  appears; `output."DP-2"` is hardcoded in `sway.nix` today.
- **`wlsunset` / `gammastep`** for night-time colour temperature.

---

# Neovim setup — things still to add

Gaps between the nixvim config and the VSCode reflexes it is trying to keep. All of these
are `src/home/nixvim.nix` unless noted. Numbered by how often the reflex actually hits
nothing today.

catppuccin 2.0 runs `auto_integrations = true` — it detects installed plugins and turns the
matching integration on itself — so anything below with an integration themes itself on
install and needs no `theme.nix` edit. Where two plugins are otherwise close, the one
catppuccin ships an integration for wins (CLAUDE.md, "Prefer apps that theme consistently").

Done and removed from this list: editor tabs (`plugins.barbar`) and format-on-demand
(`plugins.conform-nvim`, bound to `Shift+Alt+F` and `gq`, with `format_on_save` deliberately
unset).

barbar needed `nixpkgs.config.allowUnfree` set *inside* `programs.nixvim` — setting
`nixpkgs.source` makes nixvim import its own nixpkgs, which `nixpkgs.config` from the module
system never reaches. Anything else unfree pulled in through nixvim will hit the same wall.

## 1 Completion is off in TypeScript — a bug, not a gap

blink-cmp's `enabled` predicate allows `nix`, `php`, `javascript`, `javascriptreact` only,
but `ts_ls` is enabled and treesitter grammars are built for `typescript`, `tsx`, `html`,
`css` and `json`. The server attaches and diagnoses in a `.ts` file and the completion menu
never appears. Add the missing filetypes to the predicate.

## 2 `which-key`

The leader is `<Space>` and there is nothing that lists what follows it. This is the piece
that makes `<leader>f*` and `<leader>g*` stick for someone who did not grow up with them.
catppuccin integration exists.

## 3 Auto-close tags and pairs

`ts-autotag` and `nvim-autopairs`. VSCode does both silently, and JSX/TSX/PHP/HTML is
exactly what is edited here. No theming involved either way.

## 4 `Ctrl+/` and `Ctrl+s` — no plugin needed

nvim 0.10 has built-in `gc`/`gcc` commenting, so the comment toggle is one keymap. Same for
save. Both are pure muscle memory carried over from VSCode.

---

## Smaller / lower priority

- **`vim.diagnostic.config`** — nvim 0.11+ ships `virtual_text` off, so a diagnostic is a
  sign in the gutter and nothing inline. VSCode shows the message next to the code. One
  option, no plugin.
- **`trouble`** — VSCode's Problems panel. catppuccin `lsp_trouble`.
- **`grug-far`** — search *and replace* across files. Telescope's `live_grep` is only the
  finding half of `Ctrl+Shift+F`. catppuccin `grug_far`.
- **`treesitter-context`** (sticky function header) or **`dropbar`** (breadcrumbs) — both
  have catppuccin integrations.
- **`indent-blankline`** — indent guides, which VSCode draws by default.
- **`persistence`** — reopen the last session's files, as VSCode does.
- The comment at the head of `colorschemes.catppuccin` says neotree and blink_cmp are "on by
  default". It is really `auto_integrations` detecting whatever is installed — worth
  rewording, since it changes what happens when a plugin is added.

## Decided against

- **Multi-cursor** (`visual-multi`, `multicursors`) — the most-missed VSCode feature and the
  one to resist longest. It fights `.`, macros and `:%s`, which are strictly more powerful
  once they click.
- **`nvim-dap`** — VSCode's F5. A large amount of config per language; not worth it unless
  something here actually needs step-debugging.
