{
  appimageTools,
  fetchurl,
  lib,
  ...
}:
let
  pname = "ArtixGameLauncher";
  version = "2.20";
  src = fetchurl {
    url = "https://launch.artix.com/latest/Artix_Games_Launcher-x86_64.AppImage";
    sha256 = "sha256-8eVXOm5g92wErWa6lbTXrCL04MWYlObjonHJk+oUI3E=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    libGL
    mesa
  ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons
    install -m 444 -D ${appimageContents}/ArtixGamesLauncher.desktop $out/share/applications/ArtixGamesLauncher.desktop
    install -m 444 -D ${appimageContents}/ArtixLogo.png $out/share/icons/ArtixLogo.png
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
