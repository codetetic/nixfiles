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

    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = true;
      };

      # Enter on an image was landing in neovim. yazi's own default already
      # routes image/* to its `open` opener, which shells out to xdg-open, and
      # xdg-open resolves image/png to imv-dir.desktop correctly when asked
      # directly — so the indirection is what breaks, somewhere between the two.
      # Rather than leave that to chance, call imv directly and take xdg-open
      # out of the path entirely. The mime associations in bebop/home.nix still
      # cover thunar and everything else that opens images by association.
      opener.image = [
        {
          # Mirrors imv-dir.desktop: one image opens with its whole folder
          # loaded so the arrow keys walk it, which is the behaviour chosen for
          # thunar. A multi-file selection opens as just that selection.
          run = ''if [ "$#" -eq 1 ]; then imv -n "$1" "$(dirname "$1")"; else imv "$@"; fi'';
          desc = "imv";
          # imv is a GUI app: without this yazi waits on it and the terminal
          # sits blocked until the window closes.
          orphan = true;
        }
      ];

      # prepend_rules rather than rules: `rules` replaces yazi's whole default
      # table, which would strip the handling for text, video, archives and the
      # rest. prepend puts this ahead of the defaults and leaves them intact.
      open.prepend_rules = [
        {
          mime = "image/*";
          use = [ "image" ];
        }
      ];
    };

    # Upstream binds <Enter> to `open`, and its default rule for folders is
    # `{ url = "*/", use = [ "edit", "open", "reveal" ] }` — the first opener
    # wins, so Enter on a directory ran `edit` and landed in neovim. Entering a
    # directory is a command (`enter`, bound to l and <Right>), not an opener,
    # so no rule can say "open files but enter folders"; it takes a plugin that
    # picks the command from what is hovered.
    plugins.smart-enter = pkgs.writeTextDir "main.lua" ''
      -- cx is reachable only from a sync context, hence the ya.sync wrapper.
      local hovered_is_dir = ya.sync(function()
      	local h = cx.active.current.hovered
      	return h and h.cha.is_dir
      end)

      return {
      	entry = function()
      		ya.emit(hovered_is_dir() and "enter" or "open", {})
      	end,
      }
    '';

    # prepend_keymap for the same reason as prepend_rules above: `keymap`
    # replaces the whole default table. <S-Enter> still reaches the interactive
    # opener picker, which is the way to edit a folder deliberately.
    keymap.mgr.prepend_keymap = [
      {
        on = "<Enter>";
        run = "plugin smart-enter";
        desc = "Enter the directory, or open the file";
      }
    ];

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
