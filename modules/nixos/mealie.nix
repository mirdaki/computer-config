{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mealie;
in
{
  options = {
    mealie.enable = lib.mkEnableOption "enable mealie module";
    mealie.subDomainName = lib.mkOption { type = lib.types.str; };
    mealie.baseDomainName = lib.mkOption { type = lib.types.str; };

    mealie.smtpEmail = lib.mkOption { type = lib.types.str; };
    mealie.authDomainName = lib.mkOption { type = lib.types.str; };
    mealie.oidcClientId = lib.mkOption { type = lib.types.str; };

    mealie.credentialsFilePath = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
          forceSSL = true;
          useACMEHost = cfg.baseDomainName;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9000";
          };
        };
      };

      mealie = {
        enable = true;
        port = 9000;
        settings = {
          DB_ENGINE = "postgres";
          POSTGRES_URL_OVERRIDE = "postgresql://mealie:@/mealie?host=/run/postgresql";

          SMTP_HOST = "smtp.gmail.com";
          SMTP_USER = cfg.smtpEmail;
          SMTP_FROM_EMAIL = cfg.smtpEmail;

          OIDC_AUTH_ENABLED = true;
          OIDC_CONFIGURATION_URL = "https://${cfg.authDomainName}/.well-known/openid-configuration";
          OIDC_CLIENT_ID = cfg.oidcClientId;
          OIDC_ADMIN_GROUP = "mealie_admin";
          OIDC_USER_GROUP = "mealie_user";
          OIDC_PROVIDER_NAME = "Authelia";
        };
        credentialsFile = cfg.credentialsFilePath;
      };
    };

    users = {
      users.mealie = {
        group = "mealie";
        isSystemUser = true;
        # mealie wants access to the directory above
        extraGroups = [ "keys" ];
      };
      groups.mealie = { };
    };

    services.postgresql = {
      ensureDatabases = [ "mealie" ];
      ensureUsers = [
        {
          name = "mealie";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
