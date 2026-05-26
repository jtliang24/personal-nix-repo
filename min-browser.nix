{
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "min-browser";
  version = "1.35.5";

  src = fetchFromGitHub {
    owner = "minbrowser";
    repo = "min";
    rev = "${finalAttrs.version}";
    hash = "";
  };
})
