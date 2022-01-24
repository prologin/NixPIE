{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "prologin-er-background";
  version = "0.1";

  src = ../assets/login_screen.png;

  builder = pkgs.writeShellScript "builder" ''
    mkdir $out
    cp $src $out/lightdm.png
  '';
}
