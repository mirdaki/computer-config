# https://docs.mealie.io/documentation/getting-started/authentication/oidc

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.mealie-oidc;
in
{
  options = {
    mealie-oidc.enable = lib.mkEnableOption "enable mealie-oidc module";

    mealie-oidc.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_name = "Mealie";
        client_id = "KjX1OEL6sYK0zdeGdCJgoIKZ7tFdjFXvtA852RjPi4mDSD0F5ZUWpAvz8N0rKiPiwmqO";
        
        client_secret = "$pbkdf2-sha512$310000$znSUqyoV0PV7ag5LVmIHUA$o11jQ.IUn/il7aG7R39cBOxrvonNNHKE607W1XLfdcHmG7lvtFflqnYYQ7fLB/9I1JUBYtxQYMzNYTM81Seudg";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [ "https://${cfg.domainName}/login" ];
        scopes = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_basic";
      }
    ];
  };
}
