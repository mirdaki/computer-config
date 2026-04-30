{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.static-site;
in
{
  options.static-site = {
    enable = lib.mkEnableOption "enable static-site module";

    domainName = lib.mkOption { type = lib.types.str; };

    # Where the site needs to be uploaded too
    siteDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/www/${cfg.domainName}";
    };

    indexPath = lib.mkOption {
      type = lib.types.str;
      default = "index.html";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "static-site";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "static-site";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.domainName}" = {
          forceSSL = true;
          enableACME = true;
          root = cfg.siteDir;
          locations."/" = {
            index = cfg.indexPath;
            tryFiles = "$uri $uri/ $uri =404";
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.siteDir} 0777 ${cfg.user} users -"
    ];

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
