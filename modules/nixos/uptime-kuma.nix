{ config, pkgs, ... }:

{
  services = {
    nginx = {
      enable = true;
      virtualHosts."uptime-kuma.local" = {
        forceSSL = false;
        locations."/" = {
          proxyPass = "http://127.0.0.1:4000";

        };
      };
    };
    uptime-kuma = {
      enable = true;
      settings = {
        #NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
        PORT = "4000";
      };
    };
  };

  networking.extraHosts =
    ''
      127.0.0.1 uptime-kuma.local
    '';
}
