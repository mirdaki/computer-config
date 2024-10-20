{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.ntfy;
in
{
  options = {
    ntfy.enable = lib.mkEnableOption "enable ntfy module";

    ntfy.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts.${cfg.domainName} = {
          enableAuthelia = true;
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8123";
          };
        };
      };
      ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://${cfg.domainName}";
          listen-http = ":8123";
        };
      };
    };
  };
}
