# TODO: Extensions still need to be enabled via the extensions app

{ lib, config, pkgs, ... }:

let
  cfg = config.gnome-extensions;
in
{
  options = {
    gnome-extensions.enable = lib.mkEnableOption "enable gnome-extensions module";
  };

  config = lib.mkIf cfg.enable {

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" "dash-to-dock@micxgx.gmail.com" ];
        };

        "org/gnome/shell/extensions/appindicator" = {
          icon-opacity = 240;
          icon-saturation = 2.7755575615628914e-17;
        };


        "org/gnome/shell/extensions/dash-to-dock" = {
          animate-show-apps = true;
          application-counter-overrides-notifications = true;
          apply-custom-theme = true;
          background-opacity = 0.8;
          custom-theme-shrink = false;
          dash-max-icon-size = 48;
          dock-position = "BOTTOM";
          height-fraction = 0.9;
          preferred-monitor = -2;
          preferred-monitor-by-connector = "eDP-1";
          preview-size-scale = 0.0;
          show-icons-emblems = true;
          show-trash = false;
        };
      };
    };

    home.packages = with pkgs; [
      gnome.gnome-tweaks

      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-dock
    ];

  };
}
