{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.common-workstation-config;
in
{
  options = {
    common-workstation-config.enable = lib.mkEnableOption "enable common-workstation-config module";

    common-workstation-config.flakePath = lib.mkOption {
      type = lib.types.str;
      default = "/home/matthew/computer-config";
    };
  };

  config = lib.mkIf cfg.enable {
    services.fwupd.enable = true;

    services.printing.enable = true;

    system.autoUpgrade = {
      enable = true;
      # TODO: Seems to have issues, check sudo journalctl -xeu nixos-upgrade
      flake = cfg.flakePath;
      flags = [
        "-L" # print build logs
      ];
      runGarbageCollection = true;
      dates = "18:00";
      randomizedDelaySec = "45min";
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Enable sound with pipewire
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
