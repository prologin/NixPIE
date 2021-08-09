{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.nixpie.nixosModules.profiles.graphical
  ];

  cri.xfce.enable = true;
  cri.i3.enable = lib.mkForce false;

  services.xserver = {
    layout = lib.mkForce "fr,us,gb";
    displayManager = {
      setupCommands = ''
        ${pkgs.xorg.setxkbmap}/bin/setxkbmap fr,us,gb
      '';
    };
  };

  netboot = {
    enable = true;
    torrent = {
      webseed = {
        url = "https://prologin.org/static/epita-pie/";
      };
    };
  };

  cri.sddm.title = "NixOS Girls Can Code!";
  cri.salt.master = "salt.pie.prologin.dev";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev ];
  cri.programs.pythonPackages = [
    (ps: with ps; [ pygame ])
  ];

  environment.systemPackages = [
    inputs.nixpkgsMuEditor.legacyPackages.x86_64-linux.mu-editor
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0d28", MODE="0666"
  '';
}
