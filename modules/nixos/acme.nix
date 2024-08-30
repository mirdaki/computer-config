{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.acme;
in
{
  options = {
    acme.enable = lib.mkEnableOption "enable acme module";

    acme.email = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    security.acme.acceptTerms = true;
    security.acme.defaults.email = cfg.email;
  };
}
