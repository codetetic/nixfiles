# Sway setup — things still to add

Notes to self on gaps in the sway desktop. Ordered roughly by how much they
bite day to day. Package names below were all checked against the pinned
nixpkgs; the diagnoses were checked against the running system.

Done and removed from this list: GTK theming (`src/home/gtk.nix`), Qt theming
(`src/home/qt.nix`, Kvantum), lock and idle (`src/home/swaylock.nix`), flatpak
theming (`src/home/flatpak.nix`), screenshots (`src/home/screenshot.nix`),
bluetooth (`src/home/bluetooth.nix`), automount (`src/home/udiskie.nix`).

---

## 1. Waybar module gaps

Currently: `clock`, `cpu`, `memory`, `network`, `pulseaudio`,
`power-profiles-daemon`, `tray`. Worth considering:

- **`sway/scratchpad`** — this one is genuinely load-bearing given the config.
  `Mod4+Shift+space` / `Mod4+space` were rebound to move-to and show-from the
  scratchpad, and sway's own `Mod4+minus` bindings were removed, so the
  scratchpad is now the *only* place windows get hidden — with no indication
  anywhere that anything is in there. A count in the bar fixes that.
- `idle_inhibitor` — pairs with swayidle, for holding the screen on during video
- `bluetooth` — state in the bar to go with blueman's tray applet
- `temperature` / `disk` — the amdgpu box has `lact` and `openrgb` already, so
  the sensors are there

## 2. No binding to dismiss or restore notifications

`mako` is configured carefully (including `urgency=critical` notifications that
never expire), but `makoctl` is never bound to a key. A critical notification
currently has to be clicked. `makoctl dismiss` / `dismiss -a` / `restore` on
something like `Mod4+n` would finish that config off.

---

## Decided against

- **Clipboard history** (`cliphist` + rofi) — not wanted. wl-clipboard stays, as neovim's
  clipboard provider; nothing records what passes through it.
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
