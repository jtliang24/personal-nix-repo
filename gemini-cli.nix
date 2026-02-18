#based on code from Github:NixOS/nixpkgs (MIT License)
{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  pkg-config,
  clang_20,
  libsecret,
  ripgrep,
  nodejs_22,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "gemini-cli";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-89UHT+X+ryFQsE6oplCkUi5o9IDsQqvITqNGDtx7mXY=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-t91/aWQqYM2rhRUx/rrr0sIeXS9RduiKbVdSHzsf4N4=";

  nativeBuildInputs = [
    jq
    pkg-config
  ]
  ++ lib.optionals stdenv.isDarwin [ clang_20 ]; # clang_21 breaks @vscode/vsce's optionalDependencies keytar

  buildInputs = [
    ripgrep
    libsecret
  ];

  preConfigure = ''
    mkdir -p packages/generated
    echo "export const GIT_COMMIT_INFO = { commitHash: '${finalAttrs.src.rev}' };" > packages/generated/git-commit.ts
  '';

  postPatch = ''
    # Remove node-pty dependency from package.json
    ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' package.json > package.json.tmp && mv package.json.tmp package.json

    # Remove node-pty dependency from packages/core/package.json
    ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' packages/core/package.json > packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

    # Fix ripgrep path for SearchText; ensureRgPath() on its own may return the path to a dynamically-linked ripgrep binary without required libraries
    substituteInPlace packages/core/src/tools/ripGrep.ts \
      --replace-fail "await ensureRgPath();" "'${lib.getExe ripgrep}';"

    # Ideal method to disable auto-update
    sed -i '/enableAutoUpdate: {/,/}/ s/default: true/default: false/' packages/cli/src/config/settingsSchema.ts
  '';

  # Prevent npmDeps and python from getting into the closure
  disallowedReferences = [
    finalAttrs.npmDeps
    nodejs_22.python
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/gemini-cli}

    npm prune --omit=dev

    # Remove python files to prevent python from getting into the closure
    find node_modules -name "*.py" -delete

    cp -r node_modules $out/share/gemini-cli/

    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-a2a-server
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-test-utils
    rm -f $out/share/gemini-cli/node_modules/gemini-cli-vscode-ide-companion
    cp -r packages/cli $out/share/gemini-cli/node_modules/@google/gemini-cli
    cp -r packages/core $out/share/gemini-cli/node_modules/@google/gemini-cli-core
    cp -r packages/a2a-server $out/share/gemini-cli/node_modules/@google/gemini-cli-a2a-server

    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core/dist/docs/CONTRIBUTING.md

    ln -s $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/index.js $out/bin/gemini
    chmod +x "$out/bin/gemini"

    # Clean up any remaining references to npmDeps in node_modules metadata
    find $out/share/gemini-cli/node_modules -name "package-lock.json" -delete
    find $out/share/gemini-cli/node_modules -name ".package-lock.json" -delete
    find $out/share/gemini-cli/node_modules -name "config.gypi" -delete

    # Remove build artifacts that reference python
    find $out/share/gemini-cli/node_modules -name "gyp-mac-tool" -delete
    find $out/share/gemini-cli/node_modules -name "Makefile" -delete
    find $out/share/gemini-cli/node_modules -name "*.mk" -delete
    find $out/share/gemini-cli/node_modules -type d -name "obj.target" -exec rm -rf {} +

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [
      brantes
      xiaoxiangmoe
      FlameFlag
      taranarmo
    ];
    platforms = lib.platforms.all;
    mainProgram = "gemini";
  };
})
