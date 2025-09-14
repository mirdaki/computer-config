# Just a note because it took me a while to figure out, calibre-web just needs a calibre library, not calibre server running

# Manual steps
#
# Setup LDAP auth, used SSL certs for LDAPS. Othewise follow these steps
# https://github.com/lldap/lldap/blob/main/example_configs/calibre_web.md
# https://github.com/janeczku/calibre-web/wiki/LDAP-Login
#
# Email/Send to Device
# https://github.com/janeczku/calibre-web/wiki/Setup-Mailserver
# https://github.com/janeczku/calibre-web/wiki/Additional-Configuration-for-Kindle-E-Mail

# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.calibre-web-automated;
in
{
  options = {
    calibre-web-automated.enable = lib.mkEnableOption "enable calibre-web-automated module";

    calibre-web-automated.domainName = lib.mkOption { type = lib.types.str; };
    calibre-web-automated.certHostDomainName = lib.mkOption { type = lib.types.str; };

    calibre-web-automated.dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/calibre-web-automated";
    };

    calibre-web-automated.libraryDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ebooks";
    };

    calibre-web-automated.user = lib.mkOption {
      type = lib.types.str;
      default = "calibre";
    };

    calibre-web-automated.group = lib.mkOption {
      type = lib.types.str;
      default = "calibre";
    };

    calibre-web-automated.port = lib.mkOption {
      type = lib.types.port;
      default = 8083;
    };
  };

  config =
    let
      configDir = "${cfg.dataDir}/config/";
      ingestDir = "${cfg.dataDir}/ingest/";
    in
    lib.mkIf cfg.enable {

      services.nginx = {
        enable = true;
        virtualHosts."${cfg.domainName}" = {
          forceSSL = true;
          useACMEHost = cfg.certHostDomainName;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
          };
        };
        # Support larger uploads for books
        clientMaxBodySize = "500m";
      };

      # Create storage for actual media files
      systemd.tmpfiles.rules = [
        "d ${cfg.libraryDir} 0755 ${cfg.user} ${cfg.group} "
        "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} "
        "d ${configDir} 0755 ${cfg.user} ${cfg.group} "
        "d ${ingestDir} 0755 ${cfg.user} ${cfg.group} "
      ];

      # Runtime
      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
      };

      # Enable container name DNS for all Podman networks.
      networking.firewall.interfaces =
        let
          matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
        in
        {
          "${matchAll}".allowedUDPPorts = [ 53 ];
        };

      virtualisation.oci-containers.backend = "podman";

      # Containers
      virtualisation.oci-containers.containers."calibre-web-automated" = {
        image = "crocodilestick/calibre-web-automated:V3.0.4";
        environment = {
          "PGID" = "1000";
          "PUID" = "1000";
          "TZ" = "America/Los_Angeles";
        };
        volumes = [
          "${configDir}:/config:rw"
          "${ingestDir}:/cwa-book-ingest:rw"
          "${cfg.libraryDir}:/calibre-library:rw"
        ];
        ports = [
          "${builtins.toString cfg.port}:8083/tcp"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=calibre-web-automated"
          "--network=calibre-web-automated_default"
        ];
      };
      systemd.services."podman-calibre-web-automated" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
        };
        after = [
          "podman-network-calibre-web-automated_default.service"
        ];
        requires = [
          "podman-network-calibre-web-automated_default.service"
        ];
        partOf = [
          "podman-compose-calibre-web-automated-root.target"
        ];
        wantedBy = [
          "podman-compose-calibre-web-automated-root.target"
        ];
      };

      # Networks
      systemd.services."podman-network-calibre-web-automated_default" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "podman network rm -f calibre-web-automated_default";
        };
        script = ''
          podman network inspect calibre-web-automated_default || podman network create calibre-web-automated_default
        '';
        partOf = [ "podman-compose-calibre-web-automated-root.target" ];
        wantedBy = [ "podman-compose-calibre-web-automated-root.target" ];
      };

      # Root service
      # When started, this will automatically create all resources and start
      # the containers. When stopped, this will teardown all resources.
      systemd.targets."podman-compose-calibre-web-automated-root" = {
        unitConfig = {
          Description = "Root target generated by compose2nix.";
        };
        wantedBy = [ "multi-user.target" ];
      };

      users.users = {
        ${cfg.user} = {
          isSystemUser = true;
          group = cfg.group;
        };
      };

      users.groups = {
        ${cfg.group} = { };
      };

    };
}
