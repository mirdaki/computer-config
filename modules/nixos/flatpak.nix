# Using this flake for managing flatpak services and installing packages 
# https://github.com/gmodena/nix-flatpak
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.flatpak;
in
{
  options = {
    flatpak.enable = lib.mkEnableOption "enable flatpak module";

    flatpak.flatpakStore = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gnome-software;
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;

      # Remove unused runtimes on run
      uninstallUnused = true;

      update.auto = {
        enable = true;
        onCalendar = "daily";
      };
    };

    # Include a flatpak store to manage flatpaks
    environment.systemPackages = [
      cfg.flatpakStore
    ];
  };
}
