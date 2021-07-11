{ config, inputs, ... }:

{
  imports = [
    inputs.nixpie.nixosModules.profiles.graphical
  ];


  # netboot.enable = true;

  cri.sddm.title = "NixOS Girls Can Code!";
  cri.salt.master = "salt.pie.prologin.dev";

  environment.systemPackages = with config.cri.programs; dev;
}
