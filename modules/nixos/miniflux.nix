{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.miniflux;
in
{
  options = {
    miniflux.enable = lib.mkEnableOption "enable miniflux module";

    miniflux.subDomainName = lib.mkOption { type = lib.types.str; };
    miniflux.baseDomainName = lib.mkOption { type = lib.types.str; };
    miniflux.authDomainName = lib.mkOption { type = lib.types.str; };

    miniflux.adminPasswordFile = lib.mkOption { type = lib.types.str; };
    miniflux.oauth2ClientIdFile = lib.mkOption { type = lib.types.str; };
    miniflux.oauth2ClientSecretFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
          forceSSL = true;
          useACMEHost = cfg.baseDomainName;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9999";
          };
        };
      };

      miniflux = {
        enable = true;
        config = {
          BASE_URL = "https://${cfg.subDomainName}.${cfg.baseDomainName}";
          LISTEN_ADDR = "127.0.0.1:9999";

          # Don't create an admin
          CREATE_ADMIN = 0;

          # To prevent old entires from popping up if they change
          FILTER_ENTRY_MAX_AGE_DAYS = 14;
          CLEANUP_ARCHIVE_READ_DAYS = 7;

          # Disable local auth option, just use OAuth2
          DISABLE_LOCAL_AUTH = 1;

          OAUTH2_PROVIDER = "oidc";
          OAUTH2_CLIENT_ID_FILE = cfg.oauth2ClientIdFile;
          OAUTH2_CLIENT_SECRET_FILE = cfg.oauth2ClientSecretFile;
          OAUTH2_REDIRECT_URL = "https://${cfg.subDomainName}.${cfg.baseDomainName}/oauth2/oidc/callback";
          OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://${cfg.authDomainName}";
          OAUTH2_USER_CREATION = "1";
        };
      };
    };

    # Need to add this, as I restrict who can create/manage database users to the database they are named after
    # This overrides the automatic service to use miniflux instead of postgres, which was causing an error
    systemd.services.miniflux-dbsetup.serviceConfig.User = lib.mkForce "miniflux";

    users = {
      users.miniflux = {
        group = "miniflux";
        isSystemUser = true;
      };
      groups.miniflux = { };
    };

  };
}
