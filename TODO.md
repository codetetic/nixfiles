# Sway setup — things still to add

Notes to self on gaps in the sway desktop. Ordered roughly by how much they
bite day to day. Package names below were all checked against the pinned
nixpkgs; the diagnoses were checked against the running system.

Done and removed from this list: GTK theming (`src/home/gtk.nix`), Qt theming
(`src/home/qt.nix`, Kvantum), lock and idle (`src/home/swaylock.nix`).

---

## 1. Flatpak apps won't pick up the host theme

Now that `services.flatpak` is on, worth knowing before the first install:
sandboxed apps cannot read `~/.config/gtk-3.0` or any theme package from the
host store. Two halves:

- **Colour scheme** propagates for free: `xdg-desktop-portal-gtk` serves
  `org.freedesktop.appearance color-scheme` to the sandbox, and `gtk.nix`'s
  `colorScheme = "dark"` writes the dconf key it reads. So prefer-dark already
  works.
- **The widget theme itself** does not. It needs either an
  `org.gtk.Gtk3theme.<name>` runtime installed from Flathub — and there is no
  Flathub runtime for `magnetic-catppuccin-gtk` — or the theme exported into
  `~/.local/share/themes` plus a `flatpak override` granting the sandbox
  `--filesystem` access to it and to `/nix/store:ro`. The export half can be
  declarative (`xdg.dataFile`); the override half is imperative, or
  `gmodena/nix-flatpak` if it gets annoying.

## 2. No screenshot path from the keyboard

No `grim`, no `slurp` anywhere in the config. The wlr portal is wired up so
*app-initiated* capture works, but there is no key that takes a shot.

`grim` + `slurp` + `swappy` on `Print` / `Shift+Print`, with region-select and
an annotate-then-save step. swappy over satty because it is GTK 3, so
`gtk.nix`'s theme reaches it; satty is GTK 4 and would only get dark Adwaita.
All three are in nixpkgs.

## 3. No clipboard history

`wl-clipboard` is present, but only as a dependency pulled in by `nixvim.nix`
for the neovim clipboard — nothing manages history. `cliphist` fronted by rofi
would slot in with near-zero new config, since rofi is already themed and
configured with a `modes` list that could just take another entry.
home-manager has a `services.cliphist` module.

## 4. Volume, media and brightness keys are unbound

`sway.nix` has no `XF86*` bindings at all. `pactl` is on `PATH` (it is in
`programs.sway.extraPackages`) and waybar shows a `pulseaudio` module, but the
keyboard cannot actually change the volume — it has to be done through the
waybar widget or a terminal.

- Volume/mute: `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` → `wpctl` or `pactl`
- Media: `playerctl` for `XF86AudioPlay/Next/Prev` — spotifyd exposes MPRIS,
  so this works against whatever is playing through it
- `swayosd` for the on-screen bar; no catppuccin module, but it takes a
  stylesheet that can be driven off `catppuccin.flavor` the way `nixvim.nix`
  and `gtk.nix` drive theirs

Brightness (`brightnessctl`) is likely moot on a desktop with a DP monitor,
though `ddcutil` could drive the BenQ over DDC/CI if that ever matters.

## 5. Bluetooth is on but has no interface

`hardware.bluetooth.enable = true` in `bebop/hardware.nix:58`, with no manager
and no waybar module. Pairing anything currently means `bluetoothctl` by hand.
`blueman` gives an applet that lands in the existing waybar `tray`, plus a
`bluetooth` module for the bar itself.

## 6. Removable media only auto-mounts while Thunar is open

`gvfs`, `tumbler` and `thunar-volman` are all set up, which covers mounting
*from inside Thunar*. Nothing handles a USB stick plugged in while Thunar is
closed. `services.udiskie` (tray mode, so it also lands in waybar's tray) would
close that. Needs `services.udisks2.enable` on the NixOS side.

## 7. Waybar module gaps

Currently: `clock`, `cpu`, `memory`, `network`, `pulseaudio`,
`power-profiles-daemon`, `tray`. Worth considering:

- **`sway/scratchpad`** — this one is genuinely load-bearing given the config.
  `Mod4+Shift+space` / `Mod4+space` were rebound to move-to and show-from the
  scratchpad, and sway's own `Mod4+minus` bindings were removed, so the
  scratchpad is now the *only* place windows get hidden — with no indication
  anywhere that anything is in there. A count in the bar fixes that.
- `idle_inhibitor` — pairs with swayidle, for holding the screen on during video
- `bluetooth` — pairs with item 5
- `temperature` / `disk` — the amdgpu box has `lact` and `openrgb` already, so
  the sensors are there

## 8. No binding to dismiss or restore notifications

`mako` is configured carefully (including `urgency=critical` notifications that
never expire), but `makoctl` is never bound to a key. A critical notification
currently has to be clicked. `makoctl dismiss` / `dismiss -a` / `restore` on
something like `Mod4+n` would finish that config off.

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
