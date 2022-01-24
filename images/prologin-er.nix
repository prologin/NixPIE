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

  networking.hostName = {
    enable = true;
    extraCommands = ''
      iptables -A OUTPUT -d 127.0.0.0/8 -j ACCEPT
      iptables -A OUTPUT -d 10.223.7.253 -j ACCEPT
      iptables -A OUTPUT -d 10.223.7.242 -j ACCEPT
      iptables -A OUTPUT -d 10.224.21.53 -j ACCEPT
      iptables -P OUTPUT DROP

      iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    '';
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
    vscode

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
  ];

  programs.java = {
    enable = true;
  };

  cri.krb5.enable = false;
  cri.ldap.enable = false;
  cri.afs.enable = false;

  services.sssd = {
    enable = true;
    config = ''
      [sssd]
      config_file_version = 2
      services = nss, pam
      domains = LDAP

      [nss]
      override_shell = ${config.users.defaultUserShell}/bin/bash

      [domain/LDAP]
      debug_level = 9
      cache_credentials = true
      enumerate = true

      id_provider = ldap
      auth_provider = krb5

      krb5_server = auth.pie.prologin.org
      krb5_realm = PROLOGIN.ORG

      ldap_uri = ldaps://auth.pie.prologin.org
      ldap_search_base = dc=prologin,dc=org
      ldap_user_search_base = ou=users,dc=prologin,dc=org?subtree?(objectClass=posixAccount)
      ldap_group_search_base = ou=groups,dc=prologin,dc=org?subtree?(objectClass=posixGroup)
      ldap_id_use_start_tls = true
      ldap_schema = rfc2307bis
      ldap_user_gecos = cn

      entry_cache_timeout = 600
      ldap_network_timeout = 2
    '';
  };

  users.ldap = {
    enable = true;
    base = "dc=prologin,dc=org";
    server = "ldaps://auth.pie.prologin.org";
    daemon.enable = true;
  };

  cri.users.enable = lib.mkForce false;

  prologin.auth.enable = true;

  krb5 = {
    enable = true;
    libdefaults = {
      dns_lookup_kdc = true;
      default_realm = "PROLOGIN.ORG";
      dns_lookup_realm = false;
      rdns = false;
    };

    realms = {
      "PROLOGIN.ORG" = {
        kdc = [ "auth.pie.prologin.org" ];
        admin_server = "auth.pie.prologin.org";
      };
    };
  };

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
