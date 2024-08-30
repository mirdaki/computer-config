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

    uptime-kuma.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts.${cfg.domainName} = {
          forceSSL = true;
          enableACME = true;
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
  };
}
