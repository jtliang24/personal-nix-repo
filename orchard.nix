{
  lib,
  fetchurl,
  appimageTools,
}:
let
  pname = "orchard-music";
  version = "1.0.0-canary.3";
  src = fetchurl {
    url = "https://depot.sfg545.dev/downloads/canary/${version}/Orchard-Linux-x86_64.AppImage";
    hash = "sha256-KlJi/zmVeAPsKKH9nhQPNOHBtE7KndQETxGI8ixOGQM=";
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
  '';

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/usr/share/applications/orchard.desktop $out/share/applications/orchard.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/orchard.png $out/share/icons/hicolor/512x512/apps/orchard.png

    # The package is named orchard-music to avoid collision with nixpkgs orchard,
    # but the binary should still be named 'orchard'.
    ln -s $out/bin/${pname} $out/bin/orchard
  '';

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
