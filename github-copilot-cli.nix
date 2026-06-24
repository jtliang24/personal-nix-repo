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
  nix-update-script,
  cacert,
}:

let
  # As of v1.0.64 upstream split the package: the plain `@github/copilot` npm
  # tarball (and the universal `github-copilot-<version>.tgz` release asset) is
  # now just a thin `npm-loader.js` that resolves a platform-specific optional
  # dependency at runtime. The real CLI (the bundled `index.js` plus its native
  # `.node` addons) only ships in the per-platform release tarballs, so we fetch
  # those directly and select by host platform.
  platforms = {
    x86_64-linux = {
      suffix = "linux-x64";
      hash = "sha256-p2I4BHdW9wRLP8ns7wmuWBwUW2RGOuARgDtItMovxGA=";
    };
    aarch64-linux = {
      suffix = "linux-arm64";
      hash = "sha256-xcFHefIgy0BQTnIbgwH48+VK2fYHhQf8wWBq9SixNeY=";
    };
    x86_64-darwin = {
      suffix = "darwin-x64";
      hash = "sha256-DKp85sN0IuJyIHSLOCZa8uabOZtiEAVUennNlYr7nL0=";
    };
    aarch64-darwin = {
      suffix = "darwin-arm64";
      hash = "sha256-2JkfpBNV4MAJ2U2TgzOvJP4cwaGFDx58MbxmROX/8Sc=";
    };
  };
  platform =
    platforms.${stdenv.hostPlatform.system}
      or (throw "github-copilot-cli: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "github-copilot-cli";
  version = "1.0.64";

  src = fetchurl {
    url = "https://github.com/github/copilot-cli/releases/download/v${finalAttrs.version}/github-copilot-${finalAttrs.version}-${platform.suffix}.tgz";
    hash = platform.hash;
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GitHub Copilot CLI brings the power of Copilot coding agent directly to your terminal";
    homepage = "https://github.com/github/copilot-cli";
    changelog = "https://github.com/github/copilot-cli/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://www.npmjs.com/package/@github/copilot";
    platforms = builtins.attrNames platforms;
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      jtliang24
    ];
    mainProgram = "copilot";
  };
})
