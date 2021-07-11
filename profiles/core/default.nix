{ pkgs, lib, config, ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  boot.kernelPackages = pkgs.linuxPackages;

  console.font = "Lat2-Terminus16";

  services.timesyncd.servers = [ "10.224.4.2" ];

  nix = {
    package = pkgs.nixFlakes;
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

    distributedBuilds = true;

    autoOptimiseStore = true;
    gc = {
      automatic = false;
      dates = "hourly";
    };
    optimise.automatic = true;

    useSandbox = true;

    trustedUsers = [ "root" "@wheel" "@builders" ];

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
  };

  users.users.root = {
    hashedPassword = "$6$NvD1NB27$r68Iq/IIZKWt6uDpCGGWlSj2Zk/5R0kn56BjC805GW71lhIW5g6XSavrBYbCQjLzdweiGBJKrWcOPsXDwSEOd.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICubjoEBTG1O9YwaG53kR7R6e7FGH6GROpk2P4dq0/v+ leo@portemont.net"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0pnnKrvi9lrliSm+pf9HNAzs0GYLKiJk5AtSg4hhDq risson@yubikey"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaSeWbQaNasMgYB/5S9gkbeRz0ulBEQgVG/f66QfA9r j4m3s@heh"
    ];
  };

  security.protectKernelImage = true;

  environment.systemPackages = with pkgs; [
    file
    git
    htop
    iftop
    iotop
    jq
    killall
    ldns
    ncdu
    openssl
    tcpdump
    telnet
    tmux
    traceroute
    tree
    unzip
    vim
    wget
    zip
  ];

  environment.etc.issue = lib.mkForce {
    text = ''
      Cette machine est réservée par Prologin pour les stages Girls Can Code!
    '';
  };
}
