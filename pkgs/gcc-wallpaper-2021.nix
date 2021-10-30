{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  name = "gcc-wallpaper-2021";

  src = pkgs.fetchurl {
    url = "https://girlscancode.fr/static/wallpaper-2021.jpg";
    sha256 = "sha256-DXDttUQl+JqeXIo5d9j/oUMJX0eIPZD/xvrn6SgGzOU=";
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir $out
    cp $src $out/background.jpg;
  '';
}
