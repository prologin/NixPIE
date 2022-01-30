{ config, inputs, lib, pkgs, ...}:
{
  imports = [
    inputs.nixpie.nixosModules.profiles.graphical
  ];

  i18n.defaultLocale = lib.mkForce "fr_FR.UTF-8";
  i18n.supportedLocales = lib.mkForce [ "fr_FR.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

  cri.xfce.enable = true;
  cri.i3.enable = lib.mkForce false;
  cri.machine-state.enable = lib.mkForce false;
  cri.nuc-led-setter.enable = lib.mkForce false;

  networking.firewall = {
    enable = true;
    extraCommands = ''
      iptables -A OUTPUT -d 127.0.0.0/8 -j ACCEPT
      iptables -A OUTPUT -d 10.223.7.253/32 -j ACCEPT
      iptables -A OUTPUT -d 10.223.7.242/32 -j ACCEPT
      iptables -A OUTPUT -d 10.223.7.42/32 -j ACCEPT
      iptables -A OUTPUT -d 10.224.21.53/32 -j ACCEPT
      iptables -A OUTPUT -d 163.5.5.1/32 -j ACCEPT
      iptables -P OUTPUT DROP

      iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    '';
  };

  networking.hosts = {
    "10.223.7.42" = [ "demi-finale.prologin.org" ];
  };

  services.xserver = {
    layout = lib.mkForce "us,gb,fr";
    displayManager = {
      sddm.enable = lib.mkForce false;
      lightdm = {
        enable = true;
        background = "${inputs.self.packages.x86_64-linux.prologin-er-background}/login_screen.png";
        extraConfig = ''
          [SeatDefaults]
          greeter-hide-users=true
        '';
        greeters.gtk.indicators = [
          "~host"
          "~spacer"
          "~clock"
          "~spacer"
          "~session"
          "~language"
          "~layout"
          "~a11y"
          "~power"
        ];
        greeters.gtk.extraConfig = ''
          panel-position=bottom
          hide-user-image=true
        '';
      };
      setupCommands = ''
        ${pkgs.xorg.setxkbmap}/bin/setxkbmap us,fr,gb
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

  cri.sddm.title = "NixOS Prologin";
  cri.salt.master = "salt.pie.prologin.org";

  cri.programs.packages = with config.cri.programs.packageBundles; [ dev ];
  cri.programs.pythonPackages = [
    (ps: with ps; [ pygame ])
  ];

  environment.systemPackages = with pkgs; [
    i3lock
    gnome.gedit
    openldap

    firefox
    fpc
    boost
    ed
    gcc
    gdc
    gdb
    git
    htop
    lua
    mono
    tree
    nodejs
    ocaml
    php
    python310
    qtcreator
    rlwrap
    tmux
    valgrind
    wget
    zsh
    vim
    emacs
    rustc
    cargo

    codeblocks
    eclipses.eclipse-java
    geany
    ghc
    leafpad
    netbeans
    rsync
    jetbrains.pycharm-community
    atom
    jetbrains.rider
    vscode
  ];

  programs.java = {
    enable = true;
  };

  cri.krb5.enable = false;
  cri.ldap.enable = false;
  cri.afs.enable = false;

  cri.users.enable = lib.mkForce false;

  prologin.auth.enable = true;

  users.defaultUserShell = lib.mkForce pkgs.bashInteractive;
  services.logind.killUserProcesses = true;

  services.openafsClient = {
    enable = true;
    cellName = "prologin.org";
    cellServDB = [{ ip = "10.223.7.242"; dnsname = "afs.prologin.org"; }];
    cache = { diskless = true; };
    fakestat = true;
  };

  environment.extraInit = ''
    if [ "$(id -u)" -ge 10000 ]; then
      export AFS_HOME="${config.services.openafsClient.mountPoint}/${config.services.openafsClient.cellName}/user/$USER"
      ${config.services.openafsClient.packages.programs}/bin/aklog
      [ -e $HOME/afs ] || ${pkgs.coreutils}/bin/ln -s $AFS_HOME $HOME/afs
      [ -e $HOME/shared ] || ${pkgs.coreutils}/bin/ln -s ${config.services.openafsClient.mountPoint}/${config.services.openafsClient.cellName}/shared $HOME/shared
    fi
  '';
}
