{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.common-config;
in
{
  options = {
    common-config.enable = lib.mkEnableOption "enable common-config module";

    common-config.hostName = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    networking.hostName = cfg.hostName;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    time.timeZone = "America/Los_Angeles";

    networking.networkmanager.enable = true;

    nixpkgs.config.allowUnfree = true;

    # Was running into issues with the download buffer being exceeded
    # https://github.com/NixOS/nix/issues/11728
    nix.settings.download-buffer-size = 524288000; # 500MB
  };
}
