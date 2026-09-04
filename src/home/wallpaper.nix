{
  config,
  lib,
  pkgs,
  ...
}:
let
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";

  # Nebulae from wallhaven, every one of them exactly 2560x1440 so `mode` below
  # never has to letterbox on DP-2. Picked for a dark base with mauve/blue
  # accents so a rotating background does not fight the Catppuccin Mocha palette
  # the rest of the desktop is pinned to (see theme.nix) — warm or bright
  # wallpapers make waybar and the window borders look wrong.
  #
  # `artist` is the creator, where wallhaven records one as a source link or an
  # artist tag. `uploader` is only whoever posted it to wallhaven, which is
  # usually a different person — those are credited "via-" rather than "by-" in
  # the filename so the distinction survives.
  #
  # To add one: find it on wallhaven filtered to 2560x1440, then
  #   nix-prefetch-url --type sha256 <url> | xargs nix hash convert --to sri --hash-algo sha256
  nebulae = {
    "3kkl3d" = {
      title = "nebula";
      artist = "starkiteckt";
      hash = "sha256-pqSbCgh9zsN7ZYehV2m4+0EPhAVsLSZ7T3KcRo5tWOw=";
    };
    "39o65v" = {
      title = "cyan-nebula";
      uploader = "omiit";
      hash = "sha256-Xo66+pZaTX/8NW9P+J2mRiDfuUWW//d0e5SButuHHPk=";
    };
    "457d88" = {
      title = "neonspace";
      artist = "joeyjazz";
      hash = "sha256-ZrXI21M2twJ+v3/H/7cA0hyQihcnWW6eOaP8A9O4mUg=";
    };
    "47zkwv" = {
      title = "glowing-nebula";
      uploader = "antistar";
      hash = "sha256-ySrxMA8FMuoLSL5EmCtbZxTeOzial/96I+L8BTWCNsg=";
    };
    "49wgx1" = {
      title = "nebula";
      uploader = "jt42";
      hash = "sha256-bQIH0WFZr0R9Ohr0JErySNhY08f1lIqoeokuiGsaMEM=";
    };
    "76g2zy" = {
      title = "nebula";
      uploader = "antistar";
      hash = "sha256-YTUjzA57D/0Gq7fvrCCTIkhxg72fqr3cRS+v/fP6WtU=";
    };
    "8x73w2" = {
      title = "violet-nebula";
      uploader = "jt42";
      hash = "sha256-XjKcEdvfvQiyE7wVlVvucOusjsFi53jH8gfVBFgnj+4=";
    };
    "968mgd" = {
      title = "nevermore-ii";
      artist = "joeyjazz";
      hash = "sha256-PnwwI89uwNg+bfxN94gBlk6awdqQLA4Kiwh6mpxqARM=";
    };
    "e719q8" = {
      title = "nebula";
      uploader = "antistar";
      hash = "sha256-2+WSFageXPbV2E93GzgutwO1HctPJgp33VBxzGiVtPc=";
    };
    "gjjpq7" = {
      title = "nebula";
      uploader = "crit";
      hash = "sha256-oMe0e75Fc+cdCAHTncB4+3VjrWEZ8Bbx9EnDH47kziQ=";
    };
    "yjjxe7" = {
      title = "orion";
      uploader = "crit";
      hash = "sha256-JBEgDBJdgrliXSVH87gKmKvm3HeyL2d7EWmDYP9ehVQ=";
    };
    "6ox3rx" = {
      title = "starfield-nebula";
      uploader = "baybay";
      # The only PNG of the set; wallhaven serves each upload under whatever
      # extension it was posted with.
      ext = "png";
      hash = "sha256-aLxB4zMBRU4qcpSabMU0raVc6yR8yeBQZ2z85JkKl2o=";
    };
  };

  ext = w: w.ext or "jpg";
  credit = w: if w ? artist then "by-${w.artist}" else "via-${w.uploader}";

  # The wallhaven id is kept on the end so a file can be traced back to
  # wallhaven.cc/w/<id> to check its licence or find the original.
  fileName = id: w: "${w.title}-${credit w}-${id}.${ext w}";

  # wallhaven shards its CDN by the first two characters of the id.
  fetchNebula =
    id: w:
    pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/${builtins.substring 0 2 id}/wallhaven-${id}.${ext w}";
      inherit (w) hash;
    };
in
{
  # Replaces the static swaybg background set by sway.nix.
  services.wpaperd = {
    settings.default = {
      # A plain directory rather than a store path, so wallpapers dropped in by
      # hand are rotated alongside the declarative ones below.
      path = wallpaperDir;
      duration = "30m";
      sorting = "random";
      # DP-2 is 2560x1440, so images at that size fill it exactly; anything
      # else is letterboxed rather than cropped or stretched.
      mode = "fit";
    };
  };

  # Symlinked into the wallpaper directory rather than pointing wpaperd at a
  # store path, so the directory stays writable and hand-added files survive;
  # home-manager leaves anything it did not create alone.
  home.file = lib.mapAttrs' (
    id: w: lib.nameValuePair "Pictures/Wallpapers/${fileName id w}" { source = fetchNebula id w; }
  ) nebulae;
}
