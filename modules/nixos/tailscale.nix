# If using OIDC for login, will need to run tailscale up command once to auth as that user, before this works without interaction

# To get a preauth key from headscale https://headscale.net/usage/getting-started/#using-a-preauthkey

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.tailscale;
in
{
  options = {
    tailscale.enable = lib.mkEnableOption "enable tailscale module";

    tailscale.domainName = lib.mkOption { type = lib.types.str; };
    tailscale.authKeyFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services = {
      tailscale = {
        enable = true;
        authKeyFile = cfg.authKeyFile;
        extraUpFlags = [ "--login-server=https://${cfg.domainName}" ];
      };
    };

    # Needed so sops can assign the owner to this
    users = {
      users.tailscale = {
        group = "tailscale";
        isSystemUser = true;
      };
      groups.tailscale = { };
    };

    systemd.services.tailscaled-autoconnect = {
      requires = [ "headscale.service" ];
      after = [ "headscale.service" ];
    };
  };
}
