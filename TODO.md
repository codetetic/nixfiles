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
- **`xdg.portal.xdgOpenUsePortal = true`** so `xdg-open` from sandboxed and
  Electron apps routes through the portal and respects `xdg.mimeApps` (which is
  already configured in `bebop/home.nix:50`) rather than guessing.
- **The stray duplicate comment** in `sway.nix` above `keybindings` — two
  near-identical "Sway's defaults, minus…" lines, one of which is stale.
- **`system` rename warning** on every eval — something in the tree still uses
  `system` instead of `stdenv.hostPlatform.system`. Harmless, but it is noise on
  every `nixos-rebuild`.
