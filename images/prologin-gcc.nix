{ config, inputs, ... }:

{
  imports = [
    inputs.nixpie.nixosModules.profiles.graphical
  ];

  netboot.enable = true;

  cri.sddm.title = "NixOS Girls Can Code!";
  cri.salt.master = "salt.pie.prologin.dev";

  environment.systemPackages = with config.cri.programs; dev ++ [
    inputs.nixpkgsMuEditor.legacyPackages.x86_64-linux.mu-editor
  ];

  services.xserver.desktopManager = {
    xfce.enable = true;
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0d28", MODE="0666"
  '';
}
