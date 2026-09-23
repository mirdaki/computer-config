{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.dms;
in
{
  options = {
    dms.enable = lib.mkEnableOption "enable dms module";
  };

  config = lib.mkIf cfg.enable {
    environment = {

      systemPackages = with pkgs; [
        nautilus
        wev
      ];
    };

    programs = {
      dms-shell = {
        enable = true;

        systemd = {
          enable = true; # Systemd service for auto-start
          restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
        };

        # Core features
        enableSystemMonitoring = true;
        enableVPN = true;
        enableDynamicTheming = true;
        enableAudioWavelength = true;
        enableCalendarEvents = true;
      };

      niri.enable = true;
    };

    security.polkit.enable = true;
    security.pam.services.dms-shell = { };

    services = {
      displayManager.dms-greeter = {
        enable = true;

        compositor.name = "niri";
      };

      geoclue2.enable = true;
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };

    xdg.portal = {
      enable = true;
      config.niri.default = [
        "gnome"
        "gtk"
      ];
      config.niri."org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

}
