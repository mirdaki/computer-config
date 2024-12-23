{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.uptime-kuma;
in
{
  options = {
    uptime-kuma.enable = lib.mkEnableOption "enable uptime-kuma module";

    uptime-kuma.baseDomainName = lib.mkOption { type = lib.types.str; };
    uptime-kuma.subDomainName = lib.mkOption { type = lib.types.str; };

    uptime-kuma.useLocalAcme = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services = {
        nginx = {
          enable = true;
          virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
            enableAuthelia = true;
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:4000";
            };
          };
        };
        uptime-kuma = {
          enable = true;
          settings = {
            PORT = "4000";
          };
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.useLocalAcme) {
      services.nginx.virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}".useACMEHost =
        cfg.baseDomainName;
    })

    (lib.mkIf (cfg.enable && !cfg.useLocalAcme) {
      services.nginx.virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}".enableACME = true;
    })
  ];
}
