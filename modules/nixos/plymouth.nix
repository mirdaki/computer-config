# Source https://wiki.nixos.org/wiki/Plymouth and https://discourse.nixos.org/t/how-to-configure-a-graphical-boot-screen-with-luks-unlock/63357
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.plymouth;
in
{
  options = {
    plymouth.enable = lib.mkEnableOption "enable plymouth module";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = "hexagon_2";
        themePackages = with pkgs; [
          # By default we would install all themes
          # Theme soruce https://github.com/adi1090x/plymouth-themes
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "hexagon_2" ];
          })
        ];
      };

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      initrd.systemd.enable = true;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_level=3"
        "systemd.show_status=auto"
      ];
      # Hide the OS choice for bootloaders unless any key is pressed
      # loader.timeout = 0;
    };
  };
}
