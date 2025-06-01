# Instructions https://www.authelia.com/integration/openid-connect/jellyfin/

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.jellyfin-oidc;
in
{
  options = {
    jellyfin-oidc.enable = lib.mkEnableOption "enable jellyfin-oidc module";

    jellyfin-oidc.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_name = "Jellyfin";
        client_id = "70uO2ZlS-Sr.ExMkbdgnExDkaLUvZxhrjMObKclhn5vj05aVhh6sUsn3oP0DjPp2IBzT5ZMl";
        client_secret = "$pbkdf2-sha512$310000$WzCMDMvo65z7qcj0MRxkJg$7BuKYaf88V3tcdzbS1Q6kivQD58C8S39z.wzsxUZ8pR6jr3ONHa07XNBkKGR18gZhaW86dw4g4q3rmwnKo5pNg";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://${cfg.domainName}/sso/OID/redirect/authelia"
          "http://${cfg.domainName}/sso/OID/redirect/authelia"

        ];
        scopes = [
          "openid"
          "profile"
          "groups"
        ];
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_post";
      }
    ];
  };
}
