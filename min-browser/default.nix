{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  electron,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:

buildNpmPackage (finalAttrs: {
  pname = "min-browser";
  version = "1.35.5";

  src = fetchFromGitHub {
    owner = "minbrowser";
    repo = "min";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FPk/1I8tHh/ejfjZdXdwPDiE3c3knEHVHri80d/gmGU=";
  };

  npmDepsHash = "sha256-CUXxcEcecpYB10nhNz1FCRv5tvghMwo/gZPHIUlYg9I=";
  forceGitDeps = true;
  makeCacheWritable = true;

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    sed -i '/"postinstall":/d' package.json
  '';

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  npmPackFlags = [ "--omit=optional" "--ignore-scripts" ];
  npmInstallFlags = [ "--omit=optional" "--ignore-scripts" ];

  npmBuildScript = "build";

  dontNpmBuild = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/min
    cp -r * $out/lib/node_modules/min/

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/min \
      --add-flags $out/lib/node_modules/min/main.build.js \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "min";
      exec = "min %U";
      icon = "min";
      desktopName = "Min";
      genericName = "Web Browser";
      categories = [ "Network" "WebBrowser" ];
      mimeTypes = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
    })
  ];

  postInstall = ''
    # Install icons
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp $out/lib/node_modules/min/icons/icon256.png $out/share/icons/hicolor/256x256/apps/min.png
  '';

  meta = {
    description = "Fast, minimal browser that protects your privacy";
    homepage = "https://minbrowser.org";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    mainProgram = "min";
    maintainers = with lib.maintainers; [ jtliang24 ];
  };
})
