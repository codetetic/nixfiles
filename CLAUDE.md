# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A NixOS flake holding the author's personal machine configuration. One host is defined today: `bebop`
(AMD desktop, ZFS root, SwayFX on Wayland, Catppuccin Mocha everywhere).

## Commands

The shell aliases in `src/home/fish.nix` are the canonical way to build; they are defined against
`~/src/nixfiles` and `$(hostname)`:

```
nr-check    # nix flake check ~/src/nixfiles
nr-update   # nix flake update --flake ~/src/nixfiles
nr-test     # sudo nixos-rebuild test   --flake ~/src/nixfiles#$(hostname)
nr-switch   # sudo nixos-rebuild switch --flake ~/src/nixfiles#$(hostname)
nr-boot     # sudo nixos-rebuild boot   --flake ~/src/nixfiles#$(hostname)
```

To evaluate a change without activating it (the usual check after editing):

```
nixos-rebuild build --flake .#bebop
nix eval .#nixosConfigurations.bebop.config.system.build.toplevel --raw   # eval-only, faster
```

Formatting is `nix fmt` — `flake.nix` exposes a `formatter` output (`nixfmt-tree`, treefmt preconfigured
with the RFC 166 `nixfmt`), so it walks the tree itself and needs no paths. `nixd` is the LSP.
There are no tests beyond `nix flake check`.

## Architecture

### Assembly

`flake.nix` is the only place that wires things together. `mkNixosConfig { host, user }` builds a
system from four modules in a fixed order — shared first, host overrides second:

```
src/system/hardware.nix        shared: bootloader, ZFS layout, zram
src/system/<host>/hardware.nix host: kernel, disks by UUID, GPU, bluetooth, hostName/hostId
src/system/configuration.nix   shared: locale, pipewire, greetd, sway, fonts, networking, flatpak
src/system/<host>/configuration.nix  host: steam, podman/libvirtd, per-host services
```

home-manager is a NixOS module here (not a standalone flake output), with `useGlobalPkgs`, so home
config is built by the same `nixos-rebuild` and there is no separate `home-manager switch`.

### specialArgs

Three extra arguments are threaded into every system *and* home module via `specialArgs` /
`extraSpecialArgs`:

- `user` — an attrset (`name`, `description`, `email`, `keys`) declared inline in `flake.nix`.
  This is the single source of truth for the username, git identity and SSH key; modules read
  `user.email` etc. rather than hardcoding. Adding a host means declaring its own `user` there.
- `inputs` — for pulling packages straight out of flake inputs, e.g.
  `inputs.helium.packages.${pkgs.system}.default`.
- `pkgsWeekly` — a second nixpkgs instance from the `nixpkgs-weekly` input, for packages that need
  to be fresher than the chilled 26.05 channel (currently only `claude-code`). It is imported by
  hand in `flake.nix`, so `nixpkgs.config` from the module system does *not* apply to it — its
  `allowUnfree` is set at the import site.

nixpkgs is pinned to DeterminateSystems' *chilled* 26.05 via flakehub, not to a github ref.
`home-manager`, `catppuccin` and `nixvim` all track matching `26.05` release branches — bump them
together.

### Home modules

`src/home/default.nix` imports every `src/home/*.nix`; those files contain **settings only**. The
`enable` toggles for the main programs (git, fish, sway, nixvim, vscodium, waybar, rofi, …) live in
`src/system/bebop/home.nix`, so that file is the readable inventory of what the user actually runs.
Smaller helpers that have no counterpart there (mako, yazi, fzf, autotiling) do enable themselves
inside their own module.

`src/system/bebop/home.nix` also holds anything host- or account-specific: package list, keychain
keys, mime associations, lutris/proton.

### Theming

Catppuccin Mocha/mauve is applied in two disconnected places, and both must be edited for a palette
change:

- `src/home/theme.nix` — home-manager side. `catppuccin.enable = false` deliberately; each program
  is opted in individually so a new home-manager module does not silently get themed.
- `src/system/configuration.nix` — NixOS side, `catppuccin.tty.enable`, which is what colours the
  tuigreet login prompt. The palette is repeated there because those are NixOS options, not
  home-manager ones.

nixvim sets its own colorscheme (no catppuccin module exists for it) but reads
`config.catppuccin.flavor` so it still follows `theme.nix`.

**Prefer apps that theme consistently.** A visually coherent desktop is a goal of this config, not an
afterthought — when suggesting or adding a new program, weigh how it themes alongside what it does:

1. Best case, `catppuccin/nix` ships a module for it: add the program, then opt it in with a
   `<program>.enable = true` line in `src/home/theme.nix`. Check the flake's module list before
   settling on a tool; where two options are otherwise close, the one with a module wins.
2. Failing that, prefer something whose colours can be set from its own config and driven off
   `config.catppuccin.flavor` rather than a hardcoded palette, the way `nixvim.nix` does.
3. Prefer native Wayland/GTK apps that follow the system font and cursor settings over ones that
   bundle their own toolkit (Electron especially) and ignore them.

Note that `catppuccin.gtk.enable` no longer exists — the upstream GTK port was archived, so only the
icon theme is available and there is no widget theme to fall back on. That makes a program's own
theming support matter more, not less.

### Desktop session

There is no display manager stack and no X server: greetd runs on VT1, `initial_session` autologins
straight into sway at boot, and `default_session` falls back to tuigreet afterwards. Consequences
that are easy to trip over:

- Sway is installed by the NixOS module (`programs.sway.package = pkgs.swayfx`); home-manager sets
  `wayland.windowManager.sway.package = null` and owns only `~/.config/sway/config`. SwayFX-only
  options (corner_radius) have no home-manager option and go in `extraConfig`.
- Sway does not source `~/.profile`, so session-wide env (`EDITOR`, `VISUAL`, `NIXOS_OZONE_WL`) is
  set through `environment.sessionVariables` in `configuration.nix`, not in a shell module.
- Services that should track the compositor are bound to `sway-session.target`.
- The polkit agent (soteria) and keyring unlock (`security.pam.services.greetd.enableGnomeKeyring`)
  are configured explicitly because GNOME used to provide them.

## Conventions

- Comments explain **why**, and are kept when the reason is non-obvious (why a package was swapped,
  why an option is set here rather than there, what breaks without it). Match that density — this
  codebase is unusually heavily commented for a Nix config, and that is intentional.
- Host-specific values (disk UUIDs, `hostId`, monitor names like `DP-2`) belong under
  `src/system/<host>/`; anything reusable belongs in the shared module.
- Commit messages are short, lowercase, imperative-ish (`setup mako`, `remove gnome`, `improve sway config`).
