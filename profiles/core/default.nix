{ pkgs, lib, config, ... }:

{
  services.timesyncd.servers = [ "10.224.4.2" ];

  users.users.root = {
    hashedPassword = lib.mkForce "$6$NvD1NB27$r68Iq/IIZKWt6uDpCGGWlSj2Zk/5R0kn56BjC805GW71lhIW5g6XSavrBYbCQjLzdweiGBJKrWcOPsXDwSEOd.";
    openssh.authorizedKeys.keys = lib.mkForce [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICubjoEBTG1O9YwaG53kR7R6e7FGH6GROpk2P4dq0/v+ leo@portemont.net"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0pnnKrvi9lrliSm+pf9HNAzs0GYLKiJk5AtSg4hhDq risson@yubikey"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaSeWbQaNasMgYB/5S9gkbeRz0ulBEQgVG/f66QfA9r j4m3s@heh"
    ];
  };

  environment.etc.issue = lib.mkForce {
    text = ''
      Cette machine est réservée par Prologin pour les stages Girls Can Code!
    '';
  };
}
