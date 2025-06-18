{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lldap;
in
{
  options = {
    lldap.enable = lib.mkEnableOption "enable lldap module";
    lldap.domainName = lib.mkOption { type = lib.types.str; };
    lldap.ldapBaseDN = lib.mkOption { type = lib.types.str; };
    lldap.jwtSecretFile = lib.mkOption { type = lib.types.str; };
    lldap.ldapUserPassFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {

    # To expose ldap protocol outside of the server
    networking.firewall.allowedTCPPorts = [ 6360 ];

    services = {
      nginx = {
        enable = true;
        virtualHosts.${cfg.domainName} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:17170";
          };
        };
      };

      lldap = {
        enable = true;
        settings = {
          ldap_base_dn = cfg.ldapBaseDN;
          http_url = "https://${cfg.domainName}";
          database_url = "postgresql:///lldap?host=/run/postgresql";
        };
        environment = {
          LLDAP_JWT_SECRET_FILE = cfg.jwtSecretFile;
          LLDAP_LDAP_USER_PASS_FILE = cfg.ldapUserPassFile;
          LLDAP_LDAPS_OPTIONS__ENABLED = "true";
          LLDAP_LDAPS_OPTIONS__CERT_FILE = "/var/lib/acme/${cfg.domainName}/cert.pem";
          LLDAP_LDAPS_OPTIONS__KEY_FILE = "/var/lib/acme/${cfg.domainName}/key.pem";
        };
      };
    };

    # Needed so sops can assign the owner to this
    users = {
      users.lldap = {
        group = "lldap";
        isSystemUser = true;
        # Access to the acme certs
        extraGroups = [ "nginx" ];
      };
      groups.lldap = { };
    };

    services.postgresql = {
      ensureDatabases = [ "lldap" ];
      ensureUsers = [
        {
          name = "lldap";
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services.lldap = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
