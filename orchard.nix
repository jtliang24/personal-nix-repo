{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:
let
  pname = "orchard-music";
  version = "";
  src = fetchurl {
    url = "https://depot.sfg545.dev/downloads/canary/${version}/Orchard-Linux-x86_64.AppImage";
    hash = "sha256-7gHtc/yz6UEXPvqaGV4eMMs6cPnrVBhSVKlC37lbjwo=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  profile = ''
    unset QT_PLUGIN_PATH
    unset QML2_IMPORT_PATH
    export QT_QPA_PLATFORM=xcb
  '';

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/usr/share/applications/orchard.desktop $out/share/applications/orchard.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/orchard.png $out/share/icons/hicolor/512x512/apps/orchard.png

    substituteInPlace $out/share/applications/orchard.desktop \
      --replace-fail 'Exec=orchard' 'Exec=orchard-music'

    # The package is named orchard-music to avoid collision with nixpkgs orchard,
    # but the binary should still be named 'orchard'.
    ln -s $out/bin/${pname} $out/bin/orchard
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "A Youtube Music client with smart crossfade, synced lyrics, offline playback, and more";
    homepage = "https://sfg545.dev/orchard/";
    license = lib.licenses.agpl3Plus;
    mainProgram = "orchard";
    maintainers = with lib.maintainers; [ jtliang24 ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
