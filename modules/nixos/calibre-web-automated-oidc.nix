# https://github.com/crocodilestick/Calibre-Web-Automated/wiki/OAuth-Configuration

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.calibre-web-automated-oidc;
in
{
  options = {
    calibre-web-automated-oidc.enable = lib.mkEnableOption "enable calibre-web-automated-oidc module";

    calibre-web-automated-oidc.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc = {

      authorization_policies."calibre-web-automated" = {
        default_policy = "deny";
        rules = [
          {
            policy = "two_factor";
            subject = "group:internal_common";
          }
          {
            policy = "two_factor";
            subject = "group:calibre_admin";
          }
        ];
      };

      clients = [
        {
          client_name = "Calibre-Web-Automated";
          client_id = "iyO2zvJEp.V~Pt.AefBiq2FaCteLsPDevzz_XZ5jUgulV-OvhmgG2pNOrJM~falAt09DBsEZ";
          client_secret = "$pbkdf2-sha512$310000$2l2/PgPrW6GoNxRqxKTy/A$GDm01SrvPwQPIxifpxWNoTX.gslLBuAmSLZL5VCqtN4TVPIHsk5MLs1NVyQ3VfOvTXFi5.ptAcTbyjf0XYq7BQ";
          authorization_policy = "calibre-web-automated";
          redirect_uris = [ "https://${cfg.domainName}/login/generic/authorized" ];
          public = false;
          require_pkce = false;
          pkce_challenge_method = "";
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          response_types = [
            "code"
          ];
          grant_types = [
            "authorization_code"
          ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_basic";
        }
      ];
    };
  };
}
