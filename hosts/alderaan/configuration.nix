{ config, pkgs, ... }:

let
  hostName = "alderaan";
  primaryUser = "matthew";
  filesPath = "/mnt/files";
  mediaPath = "/mnt/media";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  # Standard system settings

  fileSystems.${filesPath} = {
    device = "192.168.0.205:/mnt/data/files";
    fsType = "nfs";
  };

  fileSystems.${mediaPath} = {
    device = "192.168.0.205:/mnt/data/media";
    fsType = "nfs";
  };

  # General settings

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  sops.defaultSopsFile = ./secrets/secret.yaml;
  sops.age.keyFile = "/home/${primaryUser}/.config/sops/age/keys.txt";

  programs.bash.completion.enable = true;

  sops.secrets."user/hashed-password" = { };
  sops.secrets."user/hashed-password".neededForUsers = true;

  # Custom modules

  common-config = {
    enable = true;
    hostName = cfg.hostName;
  };

  user = {
    enable = true;
    name = primaryUser;
    hashedPasswordFile = config.sops.secrets."user/hashed-password".path;
  };

  ssh.enable = true;
  ssh.allowUsername = primaryUser;

  security.enable = true;

  firewall.enable = true;

  vscode-remote-ssh.enable = true;

  # Services

  postgresql.enable = true;
  postgresql.dataDir = "${filesPath}/postgresql/${config.services.postgresql.package.psqlSchema}";
  postgresql.backupDataDir = "${filesPath}/backup/postgresql";

  nextcloud.enable = true;
  nextcloud.domainName = "cloud.i.codecaptured.com";
  nextcloud.dataDir = "${filesPath}/nextcloud";

  sops.secrets."nextcloud/admin-password".owner = "nextcloud";
  nextcloud.adminpassFile = config.sops.secrets."nextcloud/admin-password".path;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
