# Config pulled from https://wiki.nixos.org/wiki/Jellyfin

{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.jellyfin;
in
{
  options = {
    jellyfin.enable = lib.mkEnableOption "enable jellyfin module";

    jellyfin.baseDomainName = lib.mkOption { type = lib.types.str; };
    jellyfin.subDomainName = lib.mkOption { type = lib.types.str; };

    jellyfin.dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/jellyfin";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
        forceSSL = true;
        useACMEHost = cfg.baseDomainName;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
        };
      };
    };

    environment.systemPackages = [
      pkgs.jellyfin
      pkgs.jellyfin-web
      pkgs.jellyfin-ffmpeg
    ];

    # Create storage for actual media files
    systemd.tmpfiles.rules = [
      "d /mnt/media/library 0755 jellyfin jellyfin"
      "d /mnt/media/library/movies 0755 jellyfin jellyfin"
      "d /mnt/media/library/shows 0755 jellyfin jellyfin"
      "d /mnt/media/library/music 0755 jellyfin jellyfin"
    ];

    services.jellyfin = {
      enable = true;
      dataDir = cfg.dataDir;

      # For access within the home network without tailscale
      openFirewall = true;
    };
  };
}
