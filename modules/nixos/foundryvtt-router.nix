# If using OIDC for login, will need to run tailscale up command once to auth as that user, before this works without interaction

# To get a preauth key from headscale https://headscale.net/usage/getting-started/#using-a-preauthkey

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.foundryvtt-router;
in
{
  options = {
    foundryvtt-router.enable = lib.mkEnableOption "enable foundryvtt-router module";

    foundryvtt-router.domainName = lib.mkOption { type = lib.types.str; };
    foundryvtt-router.proxyPass = lib.mkOption { type = lib.types.str; };
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
            proxyWebsockets = true;
            proxyPass = "http://${cfg.proxyPass}";
          };
        };
      };
    };
  };
}
