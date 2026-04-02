{
  lib,
  fetchurl,
  makeWrapper,
  stdenvNoCC,
  ...
}:
let
  pname = "ArtixGameLauncher";
  version = "2.20";
  src = fetchurl {
    url = "https://launch.artix.com/latest/Artix_Games_Launcher-x86_64.AppImage";
    sha256 = "sha256-8eVXOm5g92wErWa6lbTXrCL04MWYlObjonHJk+oUI3E=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/libexec/ArtixGameLauncher.AppImage

    # The AppImage bundles its own runtime and must use the host's glibc/ld-linux,
    # so we run it directly rather than through an FHS sandbox.
    makeWrapper $out/libexec/ArtixGameLauncher.AppImage $out/bin/${pname} \
      --append-flags "--no-sandbox"

    mkdir -p $out/share/applications $out/share/icons
    cat > $out/share/applications/ArtixGamesLauncher.desktop << EOF
    [Desktop Entry]
    Name=Artix Game Launcher
    Exec=${pname} %u
    Icon=ArtixLogo
    Type=Application
    Categories=Game;
    MimeType=x-scheme-handler/artix;
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "The unofficial Nix packaging for the official Artix Game Launcher.";
    homepage = "https://www.artix.com/downloads/artixlauncher";
    license = licenses.unfree;
    maintainers = [ "jtliang24" ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
