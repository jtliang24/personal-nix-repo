{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "gh-aw";
  version = "0.77.5";
  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-aw";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-Hb0jjFS/aaujeP4JsaCk/Dl4vgOgZq8u0xodO+Ib/N8=";
  };

  vendorHash = "sha256-jnRL8a3xRGkN8uhsOlICKih5Fnsp6ljhpDUwjqFhbDM=";

  subPackages = [ "cmd/gh-aw" ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.version=${finalAttrs.version}"
  ];

  meta = {
    homepage = "https://github.com/github/gh-aw";
    description = "gh extension for GitHub Agentic Workflows";
    longDescription = ''
      Write agentic workflows in natural language markdown, and run them in GitHub Actions.
    '';
    changelog = "https://github.com/github/gh-aw/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://github.com/github/gh-aw/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      MH0386
      jtliang24
    ];
    mainProgram = "gh-aw";
  };
})
