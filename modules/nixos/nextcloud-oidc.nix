{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.nextcloud-oidc;
in
{
  options = {
    nextcloud-oidc.enable = lib.mkEnableOption "enable nextcloud-oidc module";

    nextcloud-oidc.domainName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main.settings.identity_providers.oidc = {

      authorization_policies."nextcloud" = {
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
          client_name = "Nextcloud";
          client_id = "yNBlkUn3ftpYOUuNhubOWCVxeFBLds57~Zjq~5mTWM5NEhkdLJuMa3dOMN624lNIEMWYfg6r";
          client_secret = "$pbkdf2-sha512$310000$E93zHUyAojUZBJrU4odBjA$JjBlTYGu8t3V267Az2dGBSlmMuNnTgnMhAn9MRLgnhfyDJa0cQ80vU9e9bf32VmvscefN3At2p3YUkIg0udXEg";
          public = false;
          authorization_policy = "nextcloud";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://${cfg.domainName}/apps/user_oidc/code" ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_post";
        }
      ];
    };
  };
}
