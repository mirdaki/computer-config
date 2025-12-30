# https://www.authelia.com/integration/openid-connect/clients/forgejo

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.forgejo-oidc;
in
{
  options = {
    forgejo-oidc.enable = lib.mkEnableOption "enable forgejo-oidc module";

    forgejo-oidc.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_name = "Forgejo";
        client_id = "rkE47JjXpNUisOHSavEVQlESKgRUgrh.97H.q5IdvQTCjF4gKy9LBgAzKUXKak4Gc3W09";
        client_secret = "$pbkdf2-sha512$310000$.ZETksJSZVcaUPffdwLiUQ$0nk7/BifitFqFNbCQjm58g8wQyRILmSfwmk/gQUpH1Me0/X/dexedXkoSnAPGZiNQviuDP0sBA7SwE7Qdw9xZA";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [ "https://${cfg.domainName}/user/oauth2/authelia/callback" ];
        scopes = [
          "openid"
          "email"
          "profile"
          "groups"
        ];
        response_types = [ "code" ];
        grant_types = [ "authorization_code" ];
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_basic";
      }
    ];
  };
}
