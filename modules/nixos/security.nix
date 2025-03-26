# Many ideas taken from this post https://xeiaso.net/blog/paranoid-nixos-2021-07-18/
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.security;
in
{
  options = {
    security.enable = lib.mkEnableOption "enable security module";
  };

  config = lib.mkIf cfg.enable {
    # Limit access to the nix package manager
    nix.settings.allowed-users = [ "@wheel" ];

    security.sudo.execWheelOnly = true;

    security.auditd.enable = true;
    security.audit.enable = true;
    security.audit.rules = [ "-a exit,always -F arch=b64 -S execve" ];
  };
}
