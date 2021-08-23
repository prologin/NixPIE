{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  name = "prologin-gcc-background";

  src = pkgs.fetchurl {
    url = "https://girlscancode.fr/static/archives/gcc/2021/poster.full.jpg";
    sha256 = "d0dcb42898c7ad93d9f4b96356007ea59a33a2aff40c70d3787d2e36ac3ce7b0";
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir $out
    cp $src $out/background.jpg;
  '';
}
