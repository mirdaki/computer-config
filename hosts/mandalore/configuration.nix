{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  hostName = "mandalore";
  primaryUser = "matthew";
  baseDomainName = "codecaptured.com";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  # Standard system settings

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Intel Arc Setup

  # https://wiki.nixos.org/wiki/Intel_Graphics
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Prefer the modern iHD backend
  };

  # May help if FFmpeg/VAAPI/QSV init fails (esp. on Arc with i915):
  hardware.enableRedistributableFirmware = true;

  # Resolve a Cosmic and Gnome bug https://discourse.nixos.org/t/graphics-glitches-in-gnome-apps/73442/2
  hardware.graphics.package = pkgs-unstable.mesa;

  # Custom modules

  common-config = {
    enable = true;
    hostName = hostName;
  };
  common-workstation-config.enable = true;

  user = {
    enable = true;
    name = primaryUser;
    shell = pkgs.nushell;
  };

  plymouth.enable = true;

  flatpak = {
    enable = true;
    flatpakStore = pkgs.cosmic-store;
  };

  # Specific package settings

  # TODO: Consider updating the module to be more configurable to not need the keys
  # or consider making a tailscale client module that supports the systray
  services = {
    tailscale = {
      enable = true;
      extraUpFlags = [ "--login-server=https://net.${baseDomainName}" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
