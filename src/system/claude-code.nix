{
  pkgs,
  user,
  ...
}:

let
  home = "/home/${user.name}";

  # Paths that must stay unreadable even if the read allowlist below is ever
  # widened. Listed once and reused across three independent mechanisms
  # (sandbox denyRead, credentials.files, permissions.deny) because each covers
  # a different code path: denyRead gates shell commands, credentials.files is
  # enforced by the credential layer, and permissions.deny is the only one that
  # reaches Claude's in-process Read/Grep/Glob tools, which never enter the
  # sandbox at all.
  secretPaths = [
    "${home}/.ssh"
    "${home}/.gnupg"
    "${home}/.azure"
    "${home}/.docker"
    "${home}/.keychain"
    "${home}/.pki"
    "${home}/.sigstore"
    "${home}/.mozilla"
    "${home}/.local/share/keyrings"
    "${home}/.claude/.credentials.json"
    "${home}/.npmrc"
    "${home}/.cargo/credentials.toml"
    "${home}/.bash_history"
    "${home}/.zsh_history"
    "${home}/.local/share/fish/fish_history"
  ];
in
{
  # Tools the agent reaches for that the base system does not already provide.
  # The sandbox inherits the system PATH rather than having one of its own, so
  # there is no way to scope these to claude-code — they land in every user's
  # PATH. Kept short for that reason: each entry is here because its absence
  # actually blocked something, not on the chance it might be handy.
  environment.systemPackages = with pkgs; [
    # Anything needing a real parser rather than sed. Structured edits to Nix
    # and JSON are the common case: a heredoc'd python script does exact string
    # replacement with an assertion on the match count, which is far safer than
    # a line-range splice that silently corrupts the file if the ranges shift.
    # Bare interpreter — the stdlib (json, re, pathlib) is the whole point, and
    # python3.withPackages would rebuild the closure for nothing.
    python3

    # Reading flake.lock and /etc/claude-code/managed-settings.json. Both are
    # generated JSON that is painful to inspect with grep and trivial with jq.
    jq

    # Filename search. ripgrep is already present and covers content, but its
    # --files mode is clumsy next to fd for "where does this file live".
    fd

    # `file` identifies what something actually is before opening it; xxd is
    # for the cases where that turns out to be binary. Reaching for `dd | tr`
    # to hex-dump is the tell that this was missing.
    file
    unixtools.xxd

    # sponge, for `cmd < f | sponge f`. Reading and writing one file in a single
    # pipeline truncates it without this, which is the failure mode behind most
    # "the file is now empty" accidents.
    moreutils
  ];

  # Machine-wide policy for claude-code. This is the *managed settings* tier:
  # it cannot be overridden by ~/.claude/settings.json or a repo's
  # .claude/settings.json, which is the whole point — the agent must not be able
  # to widen its own sandbox. Changing it means editing this file and
  # rebuilding, so loosening the boundary is always a deliberate, sudo'd act.
  environment.etc."claude-code/managed-settings.json".source =
    (pkgs.formats.json { }).generate "claude-managed-settings.json"
      {
        sandbox = {
          enabled = true;

          # Refuse to start rather than silently running unsandboxed if bwrap
          # or socat go missing. Without this a broken sandbox degrades to a
          # warning, which is the one failure mode that matters here.
          failIfUnavailable = true;

          # The user accepted unprompted execution *because* the sandbox is the
          # boundary. That trade only holds while the next option is false.
          autoAllowBashIfSandboxed = true;

          # Ignore the dangerouslyDisableSandbox escape hatch entirely.
          # Combined with autoAllowBashIfSandboxed above, leaving this true
          # would mean no boundary at all: the agent could opt any single
          # command out of the sandbox and never be prompted about it.
          allowUnsandboxedCommands = false;

          filesystem = {
            # Deny the whole home directory, then re-open only the code trees.
            # /nix/store, /etc and /usr stay readable and are not listed: nix
            # cannot evaluate anything without them, and they hold no secrets.
            denyRead = [ home ] ++ secretPaths;

            allowRead = [
              # Code lives here. This is machine-wide policy, so it cannot name
              # "the current project" — every checkout under these two roots is
              # readable, and nothing else in $HOME is.
              "${home}/Projects"

              # claude-code's own state: transcripts, memory, project config.
              # Excludes .credentials.json, which secretPaths denies above.
              "${home}/.claude"
              "${home}/.claude.json"

              # Needed for nix and git to function at all from the shell.
              # Every entry here must exist on disk: the sandbox materialises
              # each allowed path as a bind mount, and bwrap cannot create a
              # missing target inside the already read-only $HOME — it aborts
              # before running the command, taking every Bash call with it.
              # ~/.gitconfig is therefore *not* listed: home-manager writes
              # ~/.config/git/config instead, so the classic path never exists.
              "${home}/.config/nix"
              "${home}/.config/git"
              "${home}/.cache/nix"
              "${home}/.local/state/nix"
              "${home}/.nix-defexpr"
              "${home}/.nix-profile"
            ];

            # Without this, *no* Bash command runs at all. claude-code binds a
            # list of protected paths read-only into the working directory
            # (.mcp.json, .gitconfig, .gitmodules, .bashrc, .bash_profile,
            # .vscode, .git/config, .git/hooks …) so a sandboxed command cannot
            # backdoor the next session, and bwrap has to create the mount point
            # for any of them that does not exist on disk. Inside the read-only
            # bind that allowRead makes of ~/Projects it cannot, so bwrap aborts
            # before running anything: "Can't create file at …/.mcp.json:
            # Read-only file system". Granting write on the same tree makes the
            # bind writable and the mount points creatable.
            #
            # This is wider than the default, which is the working directory
            # only: a command run in one checkout can now write to another under
            # ~/Projects. Same constraint as allowRead above — machine-wide
            # policy cannot name "the current project".
            allowWrite = [ "${home}/Projects" ];

            # Stop any lower-precedence settings file from appending to
            # allowRead. Without this a project's .claude/settings.json could
            # re-open $HOME by adding a broader entry, since allowRead wins over
            # denyRead. The cost is that widening access now requires editing
            # this file.
            allowManagedReadPathsOnly = true;
          };

          credentials.files = map (path: {
            inherit path;
            mode = "deny";
          }) secretPaths;

          network = {
            # Hosts a nix build legitimately reaches. With strictAllowlist
            # below this is the whole of the network boundary: anything absent
            # is refused, not prompted for.
            allowedDomains = [
              "cache.nixos.org"
              "*.nixos.org"
              "*.cachix.org"
              "github.com"
              "*.github.com"
              "*.githubusercontent.com"
              "flakehub.com"
              "*.flakehub.com"
              "*.determinate.systems"
            ];

            # Make allowedDomains an actual boundary. Without this the list is
            # only advisory — it suppresses prompts for the hosts it names and
            # every other host still connects. Not in theory: with this unset,
            # curl to pypi.org, registry.npmjs.org and example.com all returned
            # 200 from inside the sandbox, silently and with no prompt.
            #
            # There is no middle setting. autoAllowBashIfSandboxed pre-approves
            # the whole Bash call, so there is no later point at which a single
            # unexpected host could be asked about — the choice is enforce or
            # allow everything. The cost of enforcing is that a build fetching
            # from an unlisted host fails outright rather than pausing: a
            # fetchurl to an arbitrary upstream, or an extra substituter. The
            # fix when that happens is to add the host here and rebuild.
            strictAllowlist = true;

            # The allowedDomains counterpart to allowManagedReadPathsOnly:
            # stops a project's .claude/settings.json appending to the allowlist
            # and reopening the boundary this file just closed.
            allowManagedDomainsOnly = true;

            # The nix daemon is reached over a unix socket, which the Linux
            # sandbox blocks by default. seccomp cannot filter sockets by path,
            # so there is no narrower option than all-or-nothing here, and
            # "nothing" means no nix builds, no wayland, no dbus.
            allowAllUnixSockets = true;
          };
        };

        # The sandbox only governs shell commands. Read, Grep and Glob run
        # in-process and never touch it, so the same secrets are denied again
        # here — this is the layer that actually stops `Read ~/.ssh/id_ed25519`.
        #
        # Two rules per entry, because secretPaths mixes directories with plain
        # files: the bare path catches files like .npmrc, the /** glob catches
        # everything under a directory like .ssh. A rule takes an absolute path
        # as //<path>, and these are already rooted, hence the single slash.
        permissions.deny =
          builtins.concatMap (path: [
            "Read(/${path})"
            "Read(/${path}/**)"
          ]) secretPaths
          ++ [
            # Committing is the user's call, not the agent's. Writing the tree
            # is fine — reviewing a diff is easy, and an unwanted working-tree
            # change is one `git checkout` away. A commit is a different thing:
            # it is the point where the agent's work becomes indistinguishable
            # from the user's in the history, and where authorship gets
            # attributed. So the boundary sits at the commit, not the edit.
            #
            # Unlike everything in the sandbox block above, this is a *pattern
            # match on the command string*, not a kernel-enforced boundary. It
            # stops the direct invocation and so stops the habit; it does not
            # stop a determined process, and `git -C … commit`, an alias, or a
            # commit from inside a script would not match. Treat it as a
            # guardrail against routine and accidental commits, which is what it
            # is good at, and not as containment.
            "Bash(git commit:*)"
          ];
      };
}
