{ pkgs, ... }:
{
  # The TUI half of the pair; thunar (see src/system/configuration.nix) is the
  # GUI one. yazi over ranger or lf because it is the one the catppuccin flake
  # ships a theme for, and because its image previews use the Kitty graphics
  # protocol, which ghostty speaks natively.
  programs.yazi = {
    enable = true;

    # These install a `y` wrapper rather than calling the binary directly. The
    # difference is that quitting the wrapper leaves the shell in whatever
    # directory yazi was last looking at; the bare binary drops you back where
    # you started. Fish is the interactive shell, bash the fallback, so both.
    enableFishIntegration = true;
    enableBashIntegration = true;

    # Stated rather than left to default: home.stateVersion is below 26.05, so
    # the default is still the legacy "yy". This takes the newer name now
    # instead of having it change under us at the next stateVersion bump.
    shellWrapperName = "y";

    settings.mgr = {
      show_hidden = true;
      sort_dir_first = true;
    };

    # Previewers. These go on yazi's own PATH rather than into home.packages,
    # so nothing here shadows or clutters the interactive shell: ffprobe for
    # video, 7zz for archives, pdftoppm for PDFs, file for the type detection
    # that picks between them.
    extraPackages = with pkgs; [
      file
      ffmpeg
      p7zip
      poppler-utils
      imagemagick
      jq
      fd
      ripgrep
    ];
  };
}
