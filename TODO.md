# Sway setup — things still to add

Notes to self on gaps in the sway desktop. Ordered roughly by how much they
bite day to day. Package names below were all checked against the pinned
nixpkgs; the diagnoses were checked against the running system.

---

## 1. GTK theming — Thunar is unthemed (root cause)

**The actual problem is `gtk.enable = false`.** `src/home/theme.nix` turns on
`catppuccin.gtk.icon.enable`, which sets `gtk.iconTheme` to
`catppuccin-papirus-folders` — but home-manager's whole `gtk` module is wrapped
in `mkIf cfg.enable`, so with `gtk.enable` left at its default nothing is ever
written. Confirmed on the live system: `~/.config/gtk-3.0/` contains only
`bookmarks`, there is no `settings.ini`, and `dconf.settings` evaluates to `{}`.

So Thunar falls back to stock Adwaita light, and the Papirus icons that are
already being built into the closure never get referenced by anything.

This is not just Thunar. Two other things are quietly running on the fallback:

- `rofi` sets `show-icons = true`, and rofi resolves drun icons through the GTK
  icon theme — currently hicolor only.
- `mako` sets `icons = true` with `max-icon-size = 48`, same lookup path.
- `home.pointerCursor.gtk.enable` is also `false`, so GTK apps only get the
  catppuccin cursor via the `~/.icons/default` symlink rather than being told
  about it.

**Fix:** set `gtk.enable = true` and choose a widget theme. Catppuccin's own GTK
port is archived (hence the comment already in `theme.nix`), so the options are:

| Package | Notes |
| --- | --- |
| `adw-gtk3` | Actively maintained. Makes GTK3 apps match libadwaita, so Thunar sits next to GTK4 apps consistently. Pair with `gtk-application-prefer-dark-theme = 1`. Not catppuccin-coloured. |
| `magnetic-catppuccin-gtk` | Maintained community fork; actual mocha colours. Closest to matching sway/waybar/mako. |
| `catppuccin-gtk` (1.0.3) | Still in nixpkgs, but this *is* the archived upstream port. Avoid. |

Sketch:

```nix
gtk = {
  enable = true;
  theme = {
    name = "adw-gtk3-dark";           # or "Catppuccin-GTK-Dark"
    package = pkgs.adw-gtk3;
  };
  # iconTheme is already set by catppuccin.gtk.icon; it just needs enable = true
  # above before it reaches disk.
  gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
  gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
};
home.pointerCursor.gtk.enable = true;
```

Two follow-ons:

- **A UI font is missing.** `local.fonts.mono` is the only font option, and a
  mono family is wrong for `gtk.font`. Worth adding `local.fonts.ui` (e.g. Noto
  Sans, already in `fonts.packages`) so GTK, and later Qt, share one source of
  truth the same way the mono size already does.
- **GTK4/libadwaita apps ignore themes entirely.** `adw-gtk3` only covers GTK3.
  For GTK4 the lever is the `color-scheme` preference, which the portal exposes
  — see item 3.

## 2. Qt apps have no theme at all

`qt.enable` is `false`. Nothing in the current package set is Qt-heavy so this
is latent rather than broken, but the first Qt app installed will show up in
default Fusion light. `qt.enable = true` with `qt.platformTheme = "gtk3"` makes
it follow whatever item 1 settles on, which keeps it to one decision.

## 3. Flatpak apps won't pick up the host theme

Now that `services.flatpak` is on, worth knowing before the first install:
sandboxed apps cannot read `~/.config/gtk-3.0` or any theme package from the
host store. Two halves:

- **Colour scheme** propagates for free *if* dconf is set —
  `xdg-desktop-portal-gtk` serves `org.freedesktop.appearance color-scheme` to
  the sandbox, and enabling `gtk` in item 1 writes the dconf key. So
  prefer-dark should just work once item 1 lands.
- **The widget theme itself** does not. It needs either an
  `org.gtk.Gtk3theme.<name>` runtime installed from Flathub, or a
  `flatpak override --filesystem=xdg-config/gtk-3.0:ro`. Both are imperative;
  if this gets annoying, `gmodena/nix-flatpak` would make overrides and
  installed apps declarative.

## 4. Nothing ever locks or blanks the screen

`swayidle` and `swaylock` are both in `programs.sway.extraPackages`
(`configuration.nix:138`), but **neither is configured and there is no lock
keybinding**. There is no `services.swayidle`, no `programs.swaylock`, and no
`Mod4+…+l` in `sway.nix`. The monitor stays lit indefinitely and the session
never locks.

Given the machine autologins straight into sway with no password prompt
(`initial_session` in `configuration.nix`), a lock binding is the only thing
that would ever ask for one.

```nix
services.swayidle = {
  enable = true;
  timeouts = [
    { timeout = 300;  command = "${lib.getExe pkgs.swaylock} -f"; }
    { timeout = 600;  command = "swaymsg 'output * dpms off'";
      resumeCommand = "swaymsg 'output * dpms on'"; }
  ];
  events = [ { event = "before-sleep"; command = "${lib.getExe pkgs.swaylock} -f"; } ];
};
```

`catppuccin.swaylock.enable` exists, so the lock screen can match the rest
rather than being the one unstyled surface. `swaylock-effects` is packaged if
the blur/screenshot background is wanted.

## 5. No screenshot path from the keyboard

No `grim`, no `slurp` anywhere in the config. The wlr portal is wired up so
*app-initiated* capture works, but there is no key that takes a shot.

`grim` + `slurp` + `satty` (or `swappy`) on `Print` / `Shift+Print`, with
region-select and an annotate-then-save step. All three are in nixpkgs.

## 6. No clipboard history

`wl-clipboard` is present, but only as a dependency pulled in by `nixvim.nix`
for the neovim clipboard — nothing manages history. `cliphist` fronted by rofi
would slot in with near-zero new config, since rofi is already themed and
configured with a `modes` list that could just take another entry.

## 7. Volume, media and brightness keys are unbound

`sway.nix` has no `XF86*` bindings at all. `pactl` is on `PATH` (it is in
`programs.sway.extraPackages`) and waybar shows a `pulseaudio` module, but the
keyboard cannot actually change the volume — it has to be done through the
waybar widget or a terminal.

- Volume/mute: `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` → `wpctl` or `pactl`
- Media: `playerctl` for `XF86AudioPlay/Next/Prev` — spotifyd exposes MPRIS,
  so this works against whatever is playing through it
- `swayosd` if an on-screen bar is wanted rather than silent changes

Brightness (`brightnessctl`) is likely moot on a desktop with a DP monitor,
though `ddcutil` could drive the BenQ over DDC/CI if that ever matters.

## 8. Bluetooth is on but has no interface

`hardware.bluetooth.enable = true` in `bebop/hardware.nix:58`, with no manager
and no waybar module. Pairing anything currently means `bluetoothctl` by hand.
`blueman` gives an applet that lands in the existing waybar `tray`, plus a
`bluetooth` module for the bar itself.

## 9. Removable media only auto-mounts while Thunar is open

`gvfs`, `tumbler` and `thunar-volman` are all set up, which covers mounting
*from inside Thunar*. Nothing handles a USB stick plugged in while Thunar is
closed. `services.udiskie` (tray mode, so it also lands in waybar's tray) would
close that.

## 10. Waybar module gaps

Currently: `clock`, `cpu`, `memory`, `network`, `pulseaudio`, `tray`. Worth
considering:

- **`sway/scratchpad`** — this one is genuinely load-bearing given the config.
  `Mod4+Shift+space` / `Mod4+space` were rebound to move-to and show-from the
  scratchpad, and sway's own `Mod4+minus` bindings were removed, so the
  scratchpad is now the *only* place windows get hidden — with no indication
  anywhere that anything is in there. A count in the bar fixes that.
- `idle_inhibitor` — pairs with item 4, for holding the screen on during video
- `bluetooth` — pairs with item 8
- `temperature` / `disk` — the amdgpu box has `lact` and `openrgb` already, so
  the sensors are there

## 11. No binding to dismiss or restore notifications

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
