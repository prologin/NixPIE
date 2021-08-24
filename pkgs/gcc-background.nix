{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  name = "prologin-gcc-background";

  src = pkgs.fetchurl {
    url = "https://girlscancode.fr/static/lightdm.png";
    sha256 = "84ff2002016a3dd000f05e4fe3f13b2f195db9b40eefc31a5c610acc6c38ef2e";
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir $out
    cp $src $out/background.jpg;
  '';
}
