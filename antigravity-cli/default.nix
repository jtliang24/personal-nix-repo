{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  system_dict = {
    x86_64-linux = {
      name = "linux_x64";
      hash = "sha256:6bf990458c114af3b3173dcbc1b0fb9ab93bea91c53b605fdd69aedd29a21cd9";
    };
    aarch64-linux = {
      name = "linux_arm64";
      hash = "sha256:e2f062ff8a573d2da54c03c8f0b66e130a563a08c87b6db174953a9afdd21235";
    };
    x86_64-darwin = {
      name = "mac_x64";
      hash = "sha256:53e23ef3f54d0212df7fc73ea1eb99c34e4c97bffa1f886afe565fd142c9ab89";
    };
    aarch64-darwin = {
      name = "mac_arm64";
      hash = "sha256:c00b3aa10d4eee821f7ddaf3185942c88511ebbe425663692f7732d8dd1e83c2";
    };
  };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity-cli";
  version = "1.0.13";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchurl {
    inherit
      (system_dict.${stdenv.hostPlatform.system}
        or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
      )
      hash
      ;
    url = "https://github.com/google-antigravity/antigravity-cli/releases/download/${finalAttrs.version}/agy_cli_${system_dict.${system}.name}.tar.gz";
  };

  sourceRoot = ".";

  # The source archive is a tar.gz containing the single binary named 'antigravity'.
  # The default unpackPhase will unpack it into the current directory.
  # We copy 'antigravity' to $out/bin/agy and create a symlink named 'antigravity' to it.
  # If running on macOS, we don't need any patching, but on Linux we need autoPatchelfHook.
  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.isLinux [
    zlib
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp antigravity $out/bin/agy
    ln -s agy $out/bin/antigravity-cli
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Antigravity CLI - A powerful tool for agentic workflows";
    homepage = "https://antigravity.google";
    license = licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "agy";
    maintainers = with maintainers; [
      deftdawg
      jtliang24
    ];
  };
})
