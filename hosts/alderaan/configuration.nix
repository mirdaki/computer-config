{ config, pkgs, ... }:

let
  primaryUser = "matthew";
  filesPath = "/mnt/files";
  mediaPath = "/mnt/media";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

    # Mounts
  fileSystems.${filesPath} = {
    device = "192.168.0.205:/mnt/data/files";
    fsType = "nfs";
  };

  fileSystems.${mediaPath} = {
    device = "192.168.0.205:/mnt/data/media";
    fsType = "nfs";
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "alderaan";
  time.timeZone = "America/Los_Angeles";

  sops.defaultSopsFile = ./secrets/secret.yaml;
  sops.age.keyFile = "/home/${primaryUser}/.config/sops/age/keys.txt";

  user.enable = true;
  user.name = primaryUser;

  sops.secrets."user/hashed-password" = { };
  user.hashedPasswordFile = config.sops.secrets."user/hashed-password".path;
  sops.secrets."user/hashed-password".neededForUsers = true;

  ssh.enable = true;
  ssh.allowUsername = primaryUser;

  vscode-remote-ssh.enable = true;

  security.enable = true;

  firewall.enable = true;

  # Other config
  services.fwupd.enable = true;

  programs.bash.enableCompletion = true;

  # Services
  postgresql.enable = true;
  postgresql.dataDir = "${filesPath}/postgresql/${config.services.postgresql.package.psqlSchema}";
  postgresql.backupDataDir = "${filesPath}/backup/postgresql";

  nextcloud.enable = true;
  nextcloud.domainName = "cloud.i.codecaptured.com";
  nextcloud.dataDir = "${filesPath}/nextcloud";

  sops.secrets."nextcloud/admin-password".owner = "nextcloud";
  nextcloud.adminpassFile = config.sops.secrets."nextcloud/admin-password".path;

  # Other generated on install

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
