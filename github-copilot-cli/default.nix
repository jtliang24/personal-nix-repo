{
  lib,
  stdenv,
  fetchurl,
  nodejs,
  makeBinaryWrapper,
  autoPatchelfHook,
  glib,
  libsecret,
  versionCheckHook,
  cacert,
}:

let
  versions = lib.importJSON ./versions.json;
  platform =
    versions.platforms.${stdenv.hostPlatform.system}
      or (throw "github-copilot-cli: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "github-copilot-cli";
  inherit (versions) version;

  src = fetchurl {
    url = "https://github.com/github/copilot-cli/releases/download/v${finalAttrs.version}/github-copilot-${finalAttrs.version}-${platform.suffix}.tgz";
    inherit (platform) hash;
  };

  sourceRoot = "package";

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    glib
    libsecret
  ];

  # The bundle ships optional native addons (clipboard, audio capture,
  # screen-capture, etc.) that link against GUI/media libraries which are not
  # relevant for CLI use; don't fail the build when those are missing.
  autoPatchelfIgnoreMissingDeps = true;

  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/github-copilot-cli
    cp -r . $out/lib/github-copilot-cli

    mkdir -p $out/bin
    makeBinaryWrapper ${nodejs}/bin/node $out/bin/copilot \
      --add-flags "--disable-warning=ExperimentalWarning" \
      --add-flags "$out/lib/github-copilot-cli/index.js" \
      --add-flag "--no-auto-update" \
      --prefix SSL_CERT_DIR : "${cacert}/etc/ssl/certs"

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "GitHub Copilot CLI brings the power of Copilot coding agent directly to your terminal";
    homepage = "https://github.com/github/copilot-cli";
    changelog = "https://github.com/github/copilot-cli/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://www.npmjs.com/package/@github/copilot";
    platforms = builtins.attrNames versions.platforms;
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      jtliang24
    ];
    mainProgram = "copilot";
  };
})
