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
      hash = "sha256:8391d67757496bfd14893eca6cbf0c96994bf2627566ff1f018f70600c9ef6b3";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256:d8c43bee6cf11b01eb18b95f4d7961092bc40228180808859e70dabb7784c1c9";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256:58c88032ec446e72922d911d8f03773102da20c16a6059cf21f6744bce57f210";
    };
  };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "codex";
  version = "0.171.0";

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
