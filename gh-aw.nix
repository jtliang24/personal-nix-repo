{
  lib,
  fetchFromGitHub,
  buildGoLatestModule,
  versionCheckHook,
  nix-update-script,
}:
buildGoLatestModule (finalAttrs: {
  pname = "gh-aw";
  version = "0.89.17";
  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-aw";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-pPRrRw/Hq7vSBVWhu/Ip2vr/3+X9UPYOz3+cOyIqvM8=";
  };

  vendorHash = "sha256-YydstLwmlQNoE22DAV9zZyWbeXfo0cJmSssRLVkBB/k=";

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
    extraArgs = [ "--flake" "--use-github-releases" "--version" "stable" ];
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
