# Instructions https://www.authelia.com/integration/openid-connect/home-assistant/

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.home-assistant-oidc;
in
{
  options = {
    home-assistant-oidc.enable = lib.mkEnableOption "enable home-assistant-oidc module";

    home-assistant-oidc.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc = {
      authorization_policies."home-assistant" = {
        default_policy = "deny";
        rules = [
          {
            policy = "two_factor";
            subject = "group:home_assistant_user";
          }
        ];
      };

      clients = [
        {
          client_name = "Home Assistant";
          client_id = "XZUv2OyMF5fLYUVjCNCqOD5QIhJ1i8TrAEWMfu1Fruo2xvzMutQFH6jyOrIO4PIGRM3BQ~0T";
          client_secret = "$pbkdf2-sha512$310000$iIBAw1lrYj1Z2XXKiWItMg$cfNltn1D0l6CH/EGG42O0SMbOt4piBcUGYPEW3jWocM.VYAPZdB4Ca.5rw7KCyIJnNq0hFHIgycsY6A6a8W9Og";
          public = false;
          authorization_policy = "home-assistant";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "https://${cfg.domainName}/auth/oidc/callback"
            "http://${cfg.domainName}/auth/oidc/callback"
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
  };
}
