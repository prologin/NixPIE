{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.prologin.auth;
in
{
  options.prologin.auth = {
    enable = mkEnableOption "Prologin Authentication Framework";
  };

  config =
  mkIf cfg.enable {
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
        cache_credentials = false
        enumerate = true

        id_provider = ldap
        auth_provider = krb5

        krb5_realm = PROLOGIN.ORG
        krb5_server = auth.pie.prologin.org

        ldap_uri = ldaps://auth.pie.prologin.org
        ldap_search_base = dc=prologin,dc=org
        ldap_user_search_base = ou=users,dc=prologin,dc=org?subtree?(objectClass=posixAccount)
        ldap_group_search_base = ou=groups,dc=prologin,dc=org?subtree?(objectClass=posixGroup)
        ldap_id_use_start_tls = true
        ldap_schema = rfc2307
        ldap_user_gecos = cn

        entry_cache_timeout = 600
        ldap_network_timeout = 2
      '';
    };

    krb5 = {
      enable = true;
      libdefaults = {
        default_realm = "PROLOGIN.ORG";
        dns_fallback = true;
        dns_canonicalize_hostname = false;
        rdns = false;
        forwardable = true;
      };
      realms = {
        "PROLOGIN.ORG" = {
          admin_server = "auth.pie.prologin.org";
          default_principal_flags = "+preauth";
        };
      };
    };


    services.logind.killUserProcesses = true;

    security.pam.services.login.text = ''
      # Authentication Management
      auth sufficient ${pkgs.sssd}/lib/security/pam_sss.so use_authtok
      auth required pam_unix.so try_first_pass
      auth required pam_env.so conffile=/etc/pam/environment readenv=0

      # Account management
      account sufficient ${pkgs.sssd}/lib/security/pam_sss.so
      account required pam_unix.so

      # Password management
      password sufficient ${pkgs.sssd}/lib/security/pam_sss.so use_authtok
      password required pam_unix.so try_first_pass sha512 shadow

      # Session management
      session required ${pkgs.pam}/lib/security/pam_mkhomedir.so silent skel=${config.security.pam.makeHomeDir.skelDirectory} umask=0077
      session optional ${pkgs.sssd}/lib/security/pam_sss.so
      session optional ${pkgs.systemd}/lib/security/pam_systemd.so
      session required pam_unix.so
      session required pam_env.so conffile=/etc/pam/environment readenv=0
    '';


    security.sudo.extraRules = [{
      groups = [ "pie-sudoers" ];
      commands = [ "ALL" ];
    }];
  };
}
