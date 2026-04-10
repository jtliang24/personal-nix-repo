{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs,
  unzip,
  sysctl,
  writableTmpDirAsHomeHook,
  nix-update-script,
  ripgrep,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gemini-cli-bin";
  version = "0.37.1";

  src = fetchurl {
    url = "https://github.com/google-gemini/gemini-cli/releases/download/v${finalAttrs.version}/gemini-cli-bundle.zip";
    hash = "sha256:sha256-iCjdf6HlsS0Kk/vNbs2tfz0VjYFJX6u7PwwCvHjko84=";
  };

  dontUnpack = true;

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  buildInputs = [
    nodejs
    ripgrep
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/gemini"
    unzip "$src" -d "$out/lib/gemini"
    local dest="$out/lib/gemini/gemini.js"

    # use `ripgrep` from `nixpkgs`, more dependencies but prevent downloading incompatible binary on NixOS
    # this workaround can be removed once the following upstream issue is resolved:
    # https://github.com/google-gemini/gemini-cli/issues/11438
    for file in "$out/lib/gemini"/*.js; do
      substituteInPlace "$file" \
        --replace 'const existingPath = await resolveExistingRgPath();' 'const existingPath = "${lib.getExe ripgrep}";'
      sed -i '/enableAutoUpdate: {/,/}/ s/default: true/default: false/' "$file"
    done

    makeWrapper "${lib.getExe nodejs}" "$out/bin/gemini" \
      --add-flags "--no-warnings=DEP0040" \
      --add-flags "$dest"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals (with stdenvNoCC.hostPlatform; isDarwin && isx86_64) [
    sysctl
  ];
  # versionCheckHook cannot be used because the reported version might be incorrect (e.g., 0.6.1 returns 0.6.0).
  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/gemini" -v

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script {
  };

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ljxfstorm ];
    mainProgram = "gemini";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    priority = 10;
  };
})
