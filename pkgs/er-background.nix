{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "prologin-er-background";
  version = "0.1";

  src = ../assets/login_screen.png;

  phases = [ "installPhase" ];

  installPhase = pkgs.writeShellScript "builder" ''
    mkdir $out
    cp $src $out/login_screen.png
  '';
}
