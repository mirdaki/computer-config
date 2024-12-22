# Foundry is proprietary software, so to get the actual binary, we need to pull the zip file from their website. Then follow these instructions to store it in NixOS and not be cleaned by the garbage collector.
# https://github.com/reckenrode/nix-foundryvtt?tab=readme-ov-file#preventing-garbage-collection-of-the-foundryvtt-zip-file

# I've been manually adding the zip in my home directory

{
  lib,
  config,
  pkgs,
  foundryvtt,
  ...
}:

let
  cfg = config.foundryvtt;
in
{
  options = {
    foundryvtt.enable = lib.mkEnableOption "enable foundryvtt module";

    foundryvtt.domainName = lib.mkOption { type = lib.types.str; };

    foundryvtt.dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/foundryvtt";
    };
  };

  config = lib.mkIf cfg.enable {
    services.foundryvtt = {
      enable = true;
      hostName = cfg.domainName;
      package = foundryvtt.packages.${pkgs.system}.foundryvtt_12; # Sets the version to the latest FoundryVTT v12.
      minifyStaticFiles = true;
      proxyPort = 443;
      proxySSL = true;
      upnp = false;
      dataDir = cfg.dataDir;
    };
  };
}
