{
  config,
  lib,
  pkgs,
  pkgs-25-05,
  ...
}:

let
  cfg = config.silverbullet;
in
{
  options = {
    silverbullet.enable = lib.mkEnableOption "enable silverbullet module";

    silverbullet.baseDomainName = lib.mkOption { type = lib.types.str; };
    silverbullet.subDomainName = lib.mkOption { type = lib.types.str; };

    silverbullet.dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/silverbullet";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
          enableAuthelia = true;
          forceSSL = true;
          useACMEHost = cfg.baseDomainName;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3003";
          };
        };
      };

      silverbullet = {
        enable = true;
        package = pkgs-25-05.silverbullet;
        listenPort = 3003;
        spaceDir = cfg.dataDir;
        envFile = "/etc/silverbullet.env";
      };
    };

    environment.etc."silverbullet.env" = {
      user = "silverbullet";
      text = ''
        SB_SYNC_ONLY=true
      '';
    };
  };
}
