# TODO: Add smtp and ldap_user_email

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
    lldap.httpUrl = lib.mkOption { type = lib.types.str; };
    lldap.ldapBaseDN = lib.mkOption { type = lib.types.str; };
    lldap.jwtSecretFile = lib.mkOption { type = lib.types.str; };
    lldap.ldapUserPassFile = lib.mkOption { type = lib.types.str; };
    lldap.keySeedFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
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
          http_url = cfg.httpUrl;
          database_url = "postgresql:///lldap?host=/run/postgresql";
        };
        environment = {
          LLDAP_JWT_SECRET_FILE = cfg.jwtSecretFile;
          LLDAP_LDAP_USER_PASS_FILE = cfg.ldapUserPassFile;
          LLDAP_KEY_SEED = cfg.keySeedFile;
        };
      };
    };

    # Needed so sops can assign the owner to this
    users = {
      users.lldap = {
        group = "lldap";
        isSystemUser = true;
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
