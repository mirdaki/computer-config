{ config, pkgs, ... }:

{
  services = {
    nginx = {
      enable = true;
      virtualHosts = {
        "miniflux" = {
          serverName = "miniflux.local";
          forceSSL = false;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9999";
            proxyWebsockets = true;
          };
        };
      };
    };
    # 
    miniflux = {
      enable = true;
      config = {
        BASE_URL = "http://miniflux.local";
        LISTEN_ADDR = "127.0.0.1:9999";
      };
      adminCredentialsFile = "/etc/nixos/test";
    };
  };

  networking.extraHosts =
    ''
      127.0.0.1 miniflux.local
    '';
}
