{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  installShellFiles,
  versionCheckHook,
  zlib,
}:

let
  system_dict = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256:3b8ed091149cc63a59046b9f094bcfa21cdb4dda15ede441ce369bcee4a71ba0";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256:c8d0b4ab2a97c595b70b10412d36d0d5464dcef1e1d3246b073d48017cdf5a4f";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256:8a232260df7a12c5e83e0b4b7659e1c8d9259b41942517bc0068d8ab55c36461";
    };
  };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "codex";
  version = "0.169.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchurl {
    inherit
      (system_dict.${stdenv.hostPlatform.system}
        or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
      )
      hash
      ;
    url = "https://github.com/openai/codex/releases/download/rust-v${finalAttrs.version}/codex-package-${system_dict.${system}.target}.tar.gz";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    installShellFiles
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r bin codex-package.json codex-path codex-resources $out/

    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash) \
      --fish <($out/bin/codex completion fish) \
      --zsh <($out/bin/codex completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "codex";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [
      jtliang24
    ];
  };
})
