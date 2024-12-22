# For some reason, despite trying multiple examples, the initial admin password I set never allowed logging in to the Nextcloud web UI. I can change it via the occ CLI tool and successfully login.
# nextcloud-occ user:resetpassword root

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.nextcloud;
in
{
  options = {
    nextcloud.enable = lib.mkEnableOption "enable nextcloud module";

    nextcloud.baseDomainName = lib.mkOption { type = lib.types.str; };
    nextcloud.subDomainName = lib.mkOption { type = lib.types.str; };

    nextcloud.adminpassFile = lib.mkOption { type = lib.types.str; };

    nextcloud.dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/nextcloud";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
        forceSSL = true;
        useACMEHost = cfg.baseDomainName;
      };
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;
      hostName = "${cfg.subDomainName}.${cfg.baseDomainName}";
      https = true;
      datadir = cfg.dataDir;
      autoUpdateApps.enable = true;
      autoUpdateApps.startAt = "05:00:00";
      maxUploadSize = "16G";
      # Suggested by Nextcloud's health check.
      phpOptions."opcache.interned_strings_buffer" = "16";

      settings = {
        # See other steps for OIDC (some require using the UI)
        # https://www.authelia.com/integration/openid-connect/nextcloud/#openid-connect-user-backend-app
        user_oidc = [ { use_pkce = true; } ];

        # So Nextcloud trust the SSL that nginx provides
        trusted_proxies = [
          "localhost"
          "127.0.0.1"
          "100.64.0.2" # Tailscale "proxy" node
        ];

        default_phone_region = "US";
        overwriteprotocol = "https";
      };

      config = {
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        adminuser = "admin";
        adminpassFile = cfg.adminpassFile;
      };

      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit
          calendar
          contacts
          gpoddersync
          memories
          user_oidc
          ;
      };
    };

    services.postgresql = {
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    # Nextcloud has error logs if not included, though it will eventually load correctly
    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
