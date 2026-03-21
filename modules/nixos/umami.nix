{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.umami;
in
{
  options = {
    umami.enable = lib.mkEnableOption "enable umami module";

    umami.subDomainName = lib.mkOption { type = lib.types.str; };
    umami.baseDomainName = lib.mkOption { type = lib.types.str; };

    umami.appSecretFile = lib.mkOption { type = lib.types.str; };

    umami.user = lib.mkOption {
      type = lib.types.str;
      default = "umami";
    };

    umami.group = lib.mkOption {
      type = lib.types.str;
      default = "umami";
    };

    umami.port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
          };
        };
      };

      umami = {
        enable = true;
        createPostgresqlDatabase = true;
        settings = {
          APP_SECRET_FILE = cfg.appSecretFile;
          PORT = cfg.port;
        };
      };
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
