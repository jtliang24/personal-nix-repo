{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs,
  sysctl,
  writableTmpDirAsHomeHook,
  nix-update-script,
  ripgrep,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gemini-cli-bin";
  # NOTE: pinned to v0.34.x because starting with v0.35.0 the GitHub release
  # asset `gemini.js` is no longer self-contained — it requires sibling chunk
  # files (produced by esbuild code-splitting) that are not uploaded to the
  # release.  The substituteInPlace ripgrep workaround is also broken in
  # v0.35.x because the relevant code moved into those chunk files.
  # Track upstream resolution of the release-format issue before upgrading.
  version = "0.34.0";

  src = fetchurl {
    url = "https://github.com/google-gemini/gemini-cli/releases/download/v${finalAttrs.version}/gemini.js";
    hash = "sha256-Qfol6zATjVK6d4gfA6ql3aVwjqRE7NAYqg5YTyEVDHk=";
  };

  dontUnpack = true;

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    nodejs
    ripgrep
  ];

  installPhase = ''
    runHook preInstall

    local dest="$out/lib/gemini/gemini.js"
    install -Dm644 "$src" "$dest"

    # disable auto-update
    sed -i '/enableAutoUpdate: {/,/}/ s/default: true/default: false/' "$dest"

    # use `ripgrep` from `nixpkgs`, more dependencies but prevent downloading incompatible binary on NixOS
    # this workaround can be removed once the following upstream issue is resolved:
    # https://github.com/google-gemini/gemini-cli/issues/11438
    substituteInPlace "$dest" \
      --replace-fail 'const existingPath = await resolveExistingRgPath();' 'const existingPath = "${lib.getExe ripgrep}";'

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
    # Ignore `preview` and `nightly` tags; cap at v0.34.x until the upstream
    # release format (esbuild code-splitting chunks) is resolved.
    extraArgs = [ "--version-regex=^v(0\\.34\\.[0-9]+)$" ];
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
