{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.firewall;
in
{
  options = {
    firewall.enable = lib.mkEnableOption "enable firewall module";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
    };
  };
}
