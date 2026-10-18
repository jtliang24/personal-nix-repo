{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:
let
  pname = "orchard-music";
  version = "1.0.0-canary.10";
  src = fetchurl {
    url = "https://depot.sfg545.dev/downloads/canary/${version}/Orchard-Linux-x86_64.AppImage";
    hash = "sha256-/MArqwDJSBw9NbF4+k7PFZAligpIz7/hQ6E18cZwpPw=";
    # The depot server returns HTTP 403 to requests without a browser
    # User-Agent, so fetchurl must send one (update.sh does the same).
    curlOptsList = [
      "--user-agent"
      "Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0"
    ];
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
