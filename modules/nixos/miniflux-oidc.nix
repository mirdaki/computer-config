# https://miniflux.app/docs/howto.html#oauth2

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.miniflux-oidc;
in
{
  options = {
    miniflux-oidc.enable = lib.mkEnableOption "enable miniflux-oidc module";

    miniflux-oidc.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc = {

      authorization_policies."miniflux" = {
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
          client_name = "Miniflux";
          client_id = "5DjUcAiKIaOs.pnvYk6~HKrMVwcSUaug8kYaDlddArfbx~Nu4maUajInmTh5XjYvB3gtbiWb";
          client_secret = "$pbkdf2-sha512$310000$9qwdB5Ijm4GGnANaWucspA$bDETReUXM5xij3HKTPKiM5d7XcpKtm23UXeEFQh5jJW8IWx7uqg1l62gLhJLRbgUmXOT29koTdUN.Pz8isA.iQ";
          authorization_policy = "miniflux";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://${cfg.domainName}/oauth2/oidc/callback" ];
        }
      ];
    };
  };
}
