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

  tailscale = {
    enable = true;
    domainName = "net.${baseDomainName}";
    authKeyFile = config.sops.secrets."tailscale/auth-key".path;
  };
  sops.secrets."tailscale/auth-key".owner = "tailscale";

  sops.secrets."protonvpn-exit-node/wireguard-private-key".owner = "root";

  protonvpn-exit-node-seattle = {
    enable = true;
    wireguardPrivateKeyFile = config.sops.secrets."protonvpn-exit-node/wireguard-private-key".path;
    tailscaleAuthKeyFile = config.sops.secrets."protonvpn-exit-node/seattle/tailscale-auth-key".path;
  };
  sops.secrets."protonvpn-exit-node/seattle/tailscale-auth-key".owner = "root";

  protonvpn-exit-node-losangeles = {
    enable = true;
    wireguardPrivateKeyFile = config.sops.secrets."protonvpn-exit-node/wireguard-private-key".path;
    tailscaleAuthKeyFile = config.sops.secrets."protonvpn-exit-node/losangeles/tailscale-auth-key".path;
  };
  sops.secrets."protonvpn-exit-node/losangeles/tailscale-auth-key".owner = "root";

  protonvpn-exit-node-miami = {
    enable = true;
    wireguardPrivateKeyFile = config.sops.secrets."protonvpn-exit-node/wireguard-private-key".path;
    tailscaleAuthKeyFile = config.sops.secrets."protonvpn-exit-node/miami/tailscale-auth-key".path;
  };
  sops.secrets."protonvpn-exit-node/miami/tailscale-auth-key".owner = "root";

  namecheap-private-cert = {
    enable = true;
    domainName = internalDomainName;
    credentialsFile = config.sops.secrets."namecheap-credentials".path;
  };
  sops.secrets."namecheap-credentials".owner = "acme";
  sops.secrets.namecheap-credentials = {
    sopsFile = ./secrets/namecheap-credentials.txt;
    format = "binary";
  };

  postgresql = {
    enable = true;
    dataDir = "${filesPath}/postgresql/${config.services.postgresql.package.psqlSchema}";
    backupDataDir = "${filesPath}/backup/postgresql";
  };

  nextcloud = {
    enable = true;
    baseDomainName = internalDomainName;
    subDomainName = "cloud";
    collaboraSubDomainName = "office";
    dataDir = "${filesPath}/nextcloud";
    adminpassFile = config.sops.secrets."nextcloud/admin-password".path;
  };
  sops.secrets."nextcloud/admin-password".owner = "nextcloud";

  uptime-kuma = {
    enable = true;
    baseDomainName = internalDomainName;
    subDomainName = "status";
    useLocalAcme = true;
  };

  silverbullet = {
    enable = true;
    baseDomainName = internalDomainName;
    subDomainName = "notes";
    dataDir = "${filesPath}/silverbullet";
  };

  foundryvtt = {
    enable = true;
    domainName = "vtt.${baseDomainName}";
    dataDir = "${filesPath}/foundryvtt";
  };

  miniflux = {
    enable = true;
    subDomainName = "reader";
    baseDomainName = internalDomainName;
    authDomainName = "auth.${baseDomainName}";

    adminPasswordFile = config.sops.secrets."miniflux/admin-password".path;
    oauth2ClientIdFile = config.sops.secrets."miniflux/oauth2-client-id".path;
    oauth2ClientSecretFile = config.sops.secrets."miniflux/oauth2-client-secret".path;
  };
  sops.secrets."miniflux/admin-password".owner = "miniflux";
  sops.secrets."miniflux/oauth2-client-id".owner = "miniflux";
  sops.secrets."miniflux/oauth2-client-secret".owner = "miniflux";

  jellyfin = {
    enable = true;
    baseDomainName = internalDomainName;
    subDomainName = "jellyfin";
    dataDir = "${mediaPath}/jellyfin";
  };

  mealie = {
    enable = true;
    subDomainName = "recipes";
    baseDomainName = internalDomainName;

    smtpEmail = "codecaptured@gmail.com";
    authDomainName = "auth.${baseDomainName}";
    oidcClientId = "KjX1OEL6sYK0zdeGdCJgoIKZ7tFdjFXvtA852RjPi4mDSD0F5ZUWpAvz8N0rKiPiwmqO";

    credentialsFilePath = config.sops.secrets."mealie-credentials".path;
  };
  sops.secrets."mealie-credentials".owner = "mealie";
  sops.secrets.mealie-credentials = {
    sopsFile = ./secrets/mealie-credentials.env;
    format = "binary";
  };

  flame = {
    enable = true;
    domainName = "start.${internalDomainName}";
    certHostDomainName = internalDomainName;
    dataDir = "${filesPath}/flame";
  };

  calibre-web-automated = {
    enable = true;
    domainName = "books.${internalDomainName}";
    certHostDomainName = internalDomainName;
    dataDir = "${mediaPath}/calibre-web-automated";
    libraryDir = "${mediaPath}/ebooks";
  };

  wallabag = {
    enable = true;
    domainName = "read.${internalDomainName}";
    certHostDomainName = internalDomainName;
    dataDir = "${mediaPath}/wallabag";
  };

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
