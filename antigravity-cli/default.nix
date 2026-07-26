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
      hash = "sha256:946cd06258d0ede72d0311550c914315798821f6a397f53ac760919826a19af4";
    };
    aarch64-linux = {
      name = "linux_arm64";
      hash = "sha256:0d6d488851745e80e69b8935d063e742945811b47111994b1a6dbd27df3010d5";
    };
    x86_64-darwin = {
      name = "mac_x64";
      hash = "sha256:67924f137f1ab884415fa5ab45de592d1d037eacb45be90f67d0bc6dd181498d";
    };
    aarch64-darwin = {
      name = "mac_arm64";
      hash = "sha256:1ed31957d30e2d9735b1ce545a1e9106233bf7ce07739ea1f883957f5d240bed";
    };
  };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity-cli";
  version = "1.1.7";

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
