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
      hash = "sha256:77cb69251292aa35b0b662f91f704f06dd787b72f7902a62db8c6d692989203e";
    };
    aarch64-linux = {
      name = "linux_arm64";
      hash = "sha256:b85fd6d22f763dd331bf86fde5fd33fc79ecf6ac1cb254b9c2b6519537f5694f";
    };
    aarch64-darwin = {
      name = "mac_arm64";
      hash = "sha256:95d5d8ab8870b849a157f647bb4d9953184f97855cbfbedebdedcc421ca5b435";
    };
  };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity-cli";
  version = "1.2.10";

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
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
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
      "aarch64-darwin"
    ];
    mainProgram = "agy";
    maintainers = with maintainers; [
      deftdawg
      jtliang24
    ];
  };
})
