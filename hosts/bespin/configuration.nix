{
  config,
  lib,
  pkgs,
  ...
}:

let
  primaryUser = "matthew";
  baseDomainName = "codecaptured.com";
  internalDomainName = "internal.${baseDomainName}";
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

  fileSystems.${filesPath} = {
    device = "192.168.0.205:/mnt/data/files";
    fsType = "nfs";
  };

  fileSystems.${mediaPath} = {
    device = "192.168.0.205:/mnt/data/media";
    fsType = "nfs";
  };

  # General settings

  networking.hostName = "bespin";

  time.timeZone = "America/Los_Angeles";

  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 100;

  sops.defaultSopsFile = ./secrets/secret.yaml;
  sops.age.keyFile = "/home/${primaryUser}/.config/sops/age/keys.txt";

  # Custom modules

  user.enable = true;
  user.name = primaryUser;

  sops.secrets."user/hashed-password" = { };
  user.hashedPasswordFile = config.sops.secrets."user/hashed-password".path;
  sops.secrets."user/hashed-password".neededForUsers = true;

  ssh.enable = true;
  ssh.allowUsername = primaryUser;

  security.enable = true;

  firewall.enable = true;

  vscode-remote-ssh.enable = true;

  # Services

  acme.enable = true;
  acme.email = "contact+letsencrypt.org@boowho.me";

  nginx-recommended.enable = true;

  tailscale.enable = true;
  tailscale.domainName = "net.${baseDomainName}";

  sops.secrets."tailscale/auth-key".owner = "tailscale";
  tailscale.authKeyFile = config.sops.secrets."tailscale/auth-key".path;

  namecheap-private-cert.enable = true;
  namecheap-private-cert.domainName = internalDomainName;

  sops.secrets.namecheap-credentials = {
    sopsFile = ./secrets/namecheap-credentials.txt;
    format = "binary";
  };
  sops.secrets."namecheap-credentials".owner = "acme";
  namecheap-private-cert.credentialsFile = config.sops.secrets."namecheap-credentials".path;

  postgresql.enable = true;
  postgresql.dataDir = "${filesPath}/postgresql/${config.services.postgresql.package.psqlSchema}";
  postgresql.backupDataDir = "${filesPath}/backup/postgresql";

  nextcloud.enable = true;
  nextcloud.baseDomainName = internalDomainName;
  nextcloud.subDomainName = "cloud";
  nextcloud.dataDir = "${filesPath}/nextcloud";

  sops.secrets."nextcloud/admin-password".owner = "nextcloud";
  nextcloud.adminpassFile = config.sops.secrets."nextcloud/admin-password".path;

  uptime-kuma.enable = true;
  uptime-kuma.baseDomainName = internalDomainName;
  uptime-kuma.subDomainName = "status";
  uptime-kuma.useLocalAcme = true;

  silverbullet.enable = true;
  silverbullet.baseDomainName = internalDomainName;
  silverbullet.subDomainName = "notes";
  silverbullet.dataDir = "${filesPath}/silverbullet";

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
