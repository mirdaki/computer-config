{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  hostName = "corellia";
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
  boot.initrd.luks.devices."luks-d4f044d7-81b1-4abe-a993-ed87bec2cb7d".device =
    "/dev/disk/by-uuid/d4f044d7-81b1-4abe-a993-ed87bec2cb7d";

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  sops.defaultSopsFile = ./secrets/secret.yaml;
  sops.age.keyFile = "/home/${primaryUser}/.config/sops/age/keys.txt";

  # Custom modules

  common-config = {
    enable = true;
    hostName = cfg.hostName;
  };
  common-workstation-config.enable = true;

  user = {
    enable = true;
    name = primaryUser;
    shell = pkgs.nushell;
    extraGroups = [ "docker" ];
  };

  plymouth.enable = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.nixfmt
    pkgs-unstable.ghostty
  ];

  flatpak = {
    enable = true;
    flatpakStore = pkgs.cosmic-store;
  };

  # Specific package settings

  tailscale = {
    enable = true;
    domainName = "net.${baseDomainName}";
    authKeyFile = config.sops.secrets."tailscale/auth-key".path;
  };
  sops.secrets."tailscale/auth-key".owner = config.users.users.tailscale.name;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
