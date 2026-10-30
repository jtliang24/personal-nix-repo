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
      hash = "sha256:1d44b28bc4ac9937d7d3532264baa68a507ce364956a0d4ebb856f331cdee254";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256:7821b77dda2e6283fb1f63f3165177a271da8833e857cf673c6ca1c9db3bfcc6";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256:55a440cb579f970abe7c79ab181e54b0ea4c419be99f333bbd868eebac9c21f0";
    };
  };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "codex";
  version = "0.166.0";

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
