{
  lib,
  fetchurl,
  appimageTools,
}:
let
  pname = "orchard";
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

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    install -m 444 -D ${appimageContents}/usr/share/applications/orchard.desktop $out/share/applications/orchard.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/orchard.png $out/share/icons/orchard.png
    # substituteInPlace $out/share/applications/orchard.desktop --replace-fail 'Exec=orchard' 'Exc=orchard-music'
  '';

  meta = {
    description = "A Youtube Music client with smart crossfade, synced lyrics, offline playback, and more.";
    homepage = "https://sfg545.dev/orchard/";
    license = lib.licenses.agpl3Plus;
    mainProgram = "orchard";
    platforms = [ "x86_64-linux" ];
  };
}
