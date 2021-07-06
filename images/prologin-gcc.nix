{ config, ... }:

{
  imports = [
    ../profiles/graphical
  ];

  netboot.enable = true;
  cri.sddm.title = "NixOS Girls Can Code!";
  cri.salt.master = "salt.pie.prologin.dev";


  cri.users."root".hashedPassword = "$6$exherbomasterrac$.867cc7jbttYu7QVq/ozfPic8J4ca2cxul9mPaK9FUflkf2FmrWbjCOYu8hQiTjLKrhOvBZpj5MD6dPyh57Fv.";
  cri.users."root".openssh.authorizedkeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0pnnKrvi9lrliSm+pf9HNAzs0GYLKiJk5AtSg4hhDq risson@yubikey"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICubjoEBTG1O9YwaG53kR7R6e7FGH6GROpk2P4dq0/v+ leo@portemont.net"
  ];
    

  environment.systemPackages = with config.cri.programs; dev;
}
