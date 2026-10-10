{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ripwire";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "redhat-et";
    repo = "ripwire";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6TeiT79KcEMhJI0HJIDTIOtrjmWgUxz8t8mkLpa2InQ=";
  };

  nativeBuildInputs = [ cmake ];

  # A plain `cmake --install` also runs the vendored tree-sitter's install
  # rules, dropping its headers and static lib into $out.
  installPhase = ''
    runHook preInstall
    cmake --install . --prefix $out --component ripwire
    runHook postInstall
  '';

  meta = {
    description = "Code-context CLI and MCP server for coding agents";
    homepage = "https://github.com/redhat-et/ripwire";
    license = lib.licenses.asl20;
    mainProgram = "ripwire";
    platforms = lib.platforms.linux;
  };
})
