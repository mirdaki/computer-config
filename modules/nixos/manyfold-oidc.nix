# https://manyfold.app/sysadmin/configuration.html#authentication

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.manyfold-oidc;
in
{
  options = {
    manyfold-oidc.enable = lib.mkEnableOption "enable manyfold-oidc module";

    manyfold-oidc.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc = {

      authorization_policies."manyfold" = {
        default_policy = "deny";
        rules = [
          {
            policy = "two_factor";
            subject = "group:internal_common";
          }
        ];
      };

      clients = [
        {
          client_name = "Manyfold";
          client_id = "ETcJYQcPP~W1dAGZIn1PY1t_WWN~DcAzZ-NZooqc~Q1ELHBmv-39lRERWGRVvNU.l5YY5GC5";
          client_secret = "$pbkdf2-sha512$310000$ITSqia5XYl5Nb2rk6pK2ZQ$y.ZwU8knT4Xtiu/GQTUpm1r0.HAzZICuTbvZO5/2zvrvur61P5Yvpxj2AfO1XBpodxDX9ObHOa/y32PSxaMN9A";
          authorization_policy = "manyfold";
          redirect_uris = [ "https://${cfg.domainName}/users/auth/openid_connect/callback" ];
        }
      ];
    };
  };
}
