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
      hash = "sha256:db8ca9d3c8cce0651e72b6fffa8374e2799c5554d94df2b1f9e42bb515745bff";
    };
    aarch64-linux = {
      name = "linux_arm64";
      hash = "sha256:cdbc51ffcd8a2b94991fd36c866fb0855cfaed1e2ef0ab1fcf3be7b64a3f9f71";
    };
    x86_64-darwin = {
      name = "mac_x64";
      hash = "sha256:54826c52358dc01406daf4ddb73bd620ae6b91e376bea5abc10b6e08b47f8cdf";
    };
    aarch64-darwin = {
      name = "mac_arm64";
      hash = "sha256:1c234ee8d31645bf874db1b71d5e02421c6350661c8a0f408dab310501bc5b94";
    };
  };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity-cli";
  version = "1.0.8";

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
