# Recomendations from https://nixos.wiki/wiki/Nginx#Hardened_setup_with_TLS_and_HSTS_preloading

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nginx-recommended;
in
{
  options = {
    nginx-recommended.enable = lib.mkEnableOption "enable nginx-recommended module";
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
        enable = true;

        # Use recommended settings
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        # Only allow PFS-enabled ciphers with AES256
        sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
    };
  };
}
