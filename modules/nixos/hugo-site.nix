# May need to manually make the contentDir and assign it to the uploading user

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.hugo-site;
in
{
  options = {
    hugo-site.enable = lib.mkEnableOption "enable hugo-site module";

    hugo-site.domainName = lib.mkOption { type = lib.types.str; };

    hugo-site.contentDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${cfg.domainName}";
    };

    hugo-site.siteDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/www/${cfg.domainName}";
    };

    hugo-site.user = lib.mkOption {
      type = lib.types.str;
      default = "hugo";
    };

    hugo-site.group = lib.mkOption {
      type = lib.types.str;
      default = "hugo";
    };

    hugo-site.rebuildInterval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "How often to rebuild the site (hourly, daily, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.hugo
    ];

    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.domainName}" = {
          serverName = cfg.domainName;
          forceSSL = true;
          enableACME = true;
          root = "${cfg.siteDir}";
          locations."/" = {
            index = "index.html";
            tryFiles = "$uri $uri/ $uri =404";
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.contentDir} 0777 ${cfg.user} users -"
      "d ${cfg.siteDir} 0777 ${cfg.user} users -"
    ];

    systemd.services."hugo-site-build" = {
      description = "Build Hugo site";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.hugo}/bin/hugo --minify -s ${cfg.contentDir} -d ${cfg.siteDir}";
      };
    };

    systemd.timers."hugo-site-rebuild" = {
      description = "Timer to rebuild Hugo site";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };
}
