# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
# Cleaned out values I didn't manually set

# TODO: Gnome with just dconf doesn't configure apps to startup properly yet
# https://github.com/nix-community/home-manager/issues/3447

{ lib, config, ... }:

with lib.hm.gvariant;

let
  cfg = config.gnome;
in
{
  options = {
    gnome.enable = lib.mkEnableOption "enable gnome module";
  };

  config = lib.mkIf cfg.enable {

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jxl";
          picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.jxl";
          primary-color = "#3071AE";
          secondary-color = "#000000";
        };

        "org/gnome/desktop/datetime" = {
          automatic-timezone = true;
        };

        "org/gnome/desktop/interface" = {
          clock-format = "12h";
          color-scheme = "prefer-dark";
          show-battery-percentage = true;
        };

        "org/gnome/desktop/notifications" = {
          application-children = [
            "firefox"
            "org-gnome-texteditor"
            "org-gnome-console"
            "org-gnome-settings"
            "code"
            "org-gnome-nautilus"
            "com-nextcloud-desktopclient-nextcloud"
          ];
        };

        "org/gnome/desktop/notifications/application/code" = {
          application-id = "code.desktop";
        };

        "org/gnome/desktop/notifications/application/com-nextcloud-desktopclient-nextcloud" = {
          application-id = "com.nextcloud.desktopclient.nextcloud.desktop";
        };

        "org/gnome/desktop/notifications/application/firefox" = {
          application-id = "firefox.desktop";
        };

        "org/gnome/desktop/notifications/application/gnome-power-panel" = {
          application-id = "gnome-power-panel.desktop";
        };

        "org/gnome/desktop/notifications/application/org-gnome-console" = {
          application-id = "org.gnome.Console.desktop";
        };

        "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
          application-id = "org.gnome.Nautilus.desktop";
        };

        "org/gnome/desktop/notifications/application/org-gnome-settings" = {
          application-id = "org.gnome.Settings.desktop";
        };

        "org/gnome/desktop/notifications/application/org-gnome-texteditor" = {
          application-id = "org.gnome.TextEditor.desktop";
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          click-method = "areas";
          tap-to-click = false;
        };

        "org/gnome/desktop/sound" = {
          event-sounds = true;
          theme-name = "__custom";
        };

        "org/gnome/desktop/wm/keybindings" = {
          close = [ "<Super>w" ];
          switch-applications = [ ];
          switch-applications-backward = [ ];
          switch-to-workspace-left = [ "<Control><Super>Home" ];
          switch-to-workspace-right = [ "<Control><Super>End" ];
          switch-windows = [ "<Alt>Tab" ];
          switch-windows-backward = [ "<Shift><Alt>Tab" ];
        };

        "org/gnome/desktop/wm/preferences" = {
          button-layout = "appmenu:minimize,close";
        };

        "org/gnome/mutter" = {
          dynamic-workspaces = true;
          edge-tiling = true;
        };

        "org/gnome/nautilus/icon-view" = {
          default-zoom-level = "small-plus";
        };

        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "icon-view";
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-temperature = mkUint32 3386;
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>t";
          command = "ghostty";
          name = "Terminal";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Shift><Control>Escape";
          command = "gnome-system-monitor";
          name = "System monitor";
        };

        "org/gnome/shell" = {
          favorite-apps = [
            "org.gnome.Nautilus.desktop"
            "firefox.desktop"
            "code.desktop"
            "element-desktop.desktop"
            "discord.desktop"
          ];
        };

        "org/gnome/shell/app-switcher" = {
          current-workspace-only = true;
        };

        "org/gnome/shell/keybindings" = {
          show-screenshot-ui = [ "<Shift><Super>s" ];
        };

        "org/gnome/system/location" = {
          enabled = true;
        };

        "org/gtk/settings/file-chooser" = {
          clock-format = "12h";
        };
      };
    };
  };
}
