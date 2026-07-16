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
      hash = "sha256:7a7239a69b65d3cf3af7e75f27b2ff4e9cce696a7b9a9e5c37c695f1c74eec34";
    };
    aarch64-linux = {
      name = "linux_arm64";
      hash = "sha256:453f9c5530877ab6369e2536e576cfab2bbbcb45923a9bc776678142538e419d";
    };
    x86_64-darwin = {
      name = "mac_x64";
      hash = "sha256:c12607de7e333c54799b11ccf01b83701f33464b000799ba81662640304d349a";
    };
    aarch64-darwin = {
      name = "mac_arm64";
      hash = "sha256:51627eb3df9a3a9d878ac4edb87b3f4930002f5d9bba3542d56506b60ef212a4";
    };
  };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity-cli";
  version = "1.1.3";

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
