# Postgres is discouraged by the headscale maintainers, so using SQLlite by default
# TODO: Setup a Sqlite backup job

# Create users with LLDAP, then login with that account https://headscale.net/usage/getting-started/#register-a-node
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.headscale;
in
{
  options = {
    headscale.enable = lib.mkEnableOption "enable headscale module";

    headscale.subDomainName = lib.mkOption { type = lib.types.str; };
    headscale.baseDomainName = lib.mkOption { type = lib.types.str; };
    headscale.oidcSecretFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8085";
            proxyWebsockets = true;
          };
        };
      };

      headscale = {
        enable = true;
        port = 8085;
        settings = {
          server_url = "https://${cfg.subDomainName}.${cfg.baseDomainName}:443";
          dns = {
            base_domain = "internal.${cfg.subDomainName}.${cfg.baseDomainName}";
            nameservers.global = [
              "9.9.9.9" # Quad9
              "149.112.112.112" # Quad9 backup
            ];
          };
          oidc = {
            issuer = "https://auth.${cfg.baseDomainName}";
            client_id = "6SlYc4QlKZZ3nfm27eOcCBwqIX2tiBoBr52Ur.eK2gWlab1BFEJ5McMoaxN1xEsZHXDjsvaR";
            client_secret_path = cfg.oidcSecretFile;
            strip_email_domain = true;
          };
          # Complains if I don't add this
          ip_prefixes = [
            "100.64.0.0/10"
            "fd7a:115c:a1e0::/48"
          ];
        };
      };

      authelia.instances.main.settings.identity_providers.oidc.clients = [
        {
          client_id = "6SlYc4QlKZZ3nfm27eOcCBwqIX2tiBoBr52Ur.eK2gWlab1BFEJ5McMoaxN1xEsZHXDjsvaR";
          client_name = "headscale";
          client_secret = "$pbkdf2-sha512$310000$Lk0.Ywno0TRsAcKgXwtMkA$qbtvBbeuLXIoWlC82nU9aGL.fKMhUpJd5l2/n4lRHWcp1pvBks/Zw2HsxOzlV5lTTnRzszclo0Y54GQvyyHtDw";
          authorization_policy = "two_factor";
          redirect_uris = [ "https://${cfg.subDomainName}.${cfg.baseDomainName}:443/oidc/callback" ];
          scopes = [
            "openid"
            "profile"
            "email"
          ];
        }
      ];
    };

    systemd.services.headscale = {
      requires = [ "authelia-main.service" ];
      after = [ "authelia-main.service" ];
    };
  };
}
