{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.linode;
in
{
  options = {
    linode.enable = lib.mkEnableOption "enable linode module";
  };

  # Linode recomendations from https://www.linode.com/docs/guides/install-nixos-on-linode/
  config = lib.mkIf cfg.enable {
    networking.usePredictableInterfaceNames = false;
    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;

    environment.systemPackages = with pkgs; [
      inetutils
      mtr
      sysstat
    ];

    # Use the GRUB 2 boot loader.
    boot.loader.grub.enable = true;
  };
}
