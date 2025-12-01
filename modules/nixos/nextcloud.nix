# For some reason, despite trying multiple examples, the initial admin password I set never allowed logging in to the Nextcloud web UI. I can change it via the occ CLI tool and successfully login.
# nextcloud-occ user:resetpassword root

# For collabora, needed to add public IP of server (via ping) to the allowlist in the Nextcloud admin UI

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

    nextcloud.collaboraSubDomainName = lib.mkOption { type = lib.types.str; };

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

      virtualHosts."${cfg.collaboraSubDomainName}.${cfg.baseDomainName}" = {
        forceSSL = true;
        useACMEHost = cfg.baseDomainName;

        locations."/" = {
          proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
          proxyWebsockets = true; # collabora uses websockets
        };
      };
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;
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

        # Defaults from here https://github.com/nextcloud/server/blob/master/config/config.sample.php#L1486
        # Needed to make them explicit to add HEIC
        enabledPreviewProviders = [
          "OC\\Preview\\Image"
          "OC\\Preview\\Movie"
          "OC\\Preview\\PDF"
          "OC\\Preview\\MSOfficeDoc"
          "OC\\Preview\\MSOffice"
          "OC\\Preview\\Photoshop"
          "OC\\Preview\\SVG"
          "OC\\Preview\\TIFF"

          "OC\\Preview\\HEIC"
        ];
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
          # TODO: Recognize fails to run due to a js error. Will try again with an update
          # recognize
          richdocuments
          user_oidc
          ;
      };
    };

    # From https://diogotc.com/blog/collabora-nextcloud-nixos/
    services.collabora-online = {
      enable = true;
      port = 9980;
      settings = {
        # Rely on reverse proxy for SSL
        ssl = {
          enable = false;
          termination = true;
        };

        # Listen on loopback interface only, and accept requests from ::1
        net = {
          listen = "loopback";
          post_allow.host = [ "::1" ];
        };

        # Restrict loading documents from WOPI Host
        storage.wopi = {
          "@allow" = true;
          host = [ "https://${cfg.subDomainName}.${cfg.baseDomainName}" ];
        };

        # Set FQDN of server
        server_name = "${cfg.collaboraSubDomainName}.${cfg.baseDomainName}";
      };
    };

    systemd.services."nextcloud-config-collabora" =
      let
        inherit (config.services.nextcloud) occ;

        wopi_url = "http://[::1]:${toString config.services.collabora-online.port}";
        public_wopi_url = "https://${cfg.collaboraSubDomainName}.${cfg.baseDomainName}";
        wopi_allowlist = lib.concatStringsSep "," [
          "127.0.0.1"
          "::1"
          # Needed to add the tailscale IP, so just doing the whole subnet
          "100.64.0.0/10"
        ];
      in
      {
        wantedBy = [ "multi-user.target" ];
        after = [
          "nextcloud-setup.service"
          "coolwsd.service"
        ];
        requires = [ "coolwsd.service" ];
        script = ''
          ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
          ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
          ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
          ${occ}/bin/nextcloud-occ richdocuments:setup
        '';
        serviceConfig = {
          Type = "oneshot";
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
