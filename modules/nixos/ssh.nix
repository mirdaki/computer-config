{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.ssh;
in
{
  options = {
    ssh.enable = lib.mkEnableOption "enable ssh module";

    ssh.allowUsername = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      allowSFTP = false;
      settings = {
        PasswordAuthentication = false;
        AllowUsers = [ cfg.allowUsername ];
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "no";
      };
      extraConfig = ''
        AllowTcpForwarding yes
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
    services.fail2ban.enable = true;
  };
}
