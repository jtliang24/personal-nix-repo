{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "gh-aw";
  version = "0.81.6";
  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-aw";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-OgD4LjGayLeAknzf4EudypGcyhSNUbymHRChJ/wKnBc=";
  };

  vendorHash = "sha256-fDt1ETeYE2AV/SWkzuYe5GWyFD1/y9kpJw/JT35hxno=";

  subPackages = [ "cmd/gh-aw" ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--use-github-releases" "--version" "stable" ];
  };

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
