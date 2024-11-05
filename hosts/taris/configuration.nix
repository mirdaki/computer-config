{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "taris";
  time.timeZone = "America/Los_Angeles";

  sops.defaultSopsFile = ./secrets/secret.yaml;
  sops.age.keyFile = "/home/matthew/.config/sops/age/keys.txt";

  user.enable = true;
  user.name = "matthew";
  sops.secrets."user/hashed-password" = { };
  user.hashedPasswordFile = config.sops.secrets."user/hashed-password".path;
  sops.secrets."user/hashed-password".neededForUsers = true;

  ssh.enable = true;
  ssh.allowUsername = "matthew";

  security.enable = true;

  firewall.enable = true;

  vscode-remote-ssh.enable = true;

  programs.bash.enableCompletion = true;

  linode.enable = true;

  # Services
  acme.enable = true;
  acme.email = "contact+letsencrypt.org@boowho.me";

  nginx-recommended.enable = true;

  postgresql.enable = true;

  uptime-kuma.enable = false;
  uptime-kuma.domainName = "status.codecaptured.com";

  lldap.enable = true;
  lldap.domainName = "ldap.codecaptured.com";
  lldap.httpUrl = "https://ldap.codecaptured.com";
  lldap.ldapBaseDN = "dc=codecaptured,dc=com";

  sops.secrets."lldap/jwt-secret".owner = "lldap";
  lldap.jwtSecretFile = config.sops.secrets."lldap/jwt-secret".path;
  sops.secrets."lldap/ldap-user-pass".owner = "lldap";
  lldap.ldapUserPassFile = config.sops.secrets."lldap/ldap-user-pass".path;
  sops.secrets."lldap/key-seed".owner = "lldap";
  lldap.keySeedFile = config.sops.secrets."lldap/key-seed".path;

  authelia.enable = true;
  authelia.subDomainName = "auth";
  authelia.baseDomainName = "codecaptured.com";
  authelia.ldapBaseDN = "dc=codecaptured,dc=com";
  authelia.smtpUsername = "codecaptured@gmail.com";

  sops.secrets."authelia/jwt-secret".owner = "authelia-main";
  authelia.jwtSecretFile = config.sops.secrets."authelia/jwt-secret".path;
  sops.secrets."authelia/lldap-password".owner = "authelia-main";
  authelia.lldapPasswordFile = config.sops.secrets."authelia/lldap-password".path;
  sops.secrets."authelia/oidc-hmac-secret".owner = "authelia-main";
  authelia.oidcHmacSecretFile = config.sops.secrets."authelia/oidc-hmac-secret".path;
  sops.secrets.authelia-oidc-issuer-private-key = {
    sopsFile = ./secrets/oidc-issuer-private-key.pem;
    format = "binary";
  };
  sops.secrets."authelia-oidc-issuer-private-key".owner = "authelia-main";
  authelia.oidcIssuerPrivateKeyFile = config.sops.secrets."authelia-oidc-issuer-private-key".path;
  sops.secrets."authelia/session-secret".owner = "authelia-main";
  authelia.sessionSecretFile = config.sops.secrets."authelia/session-secret".path;
  sops.secrets."authelia/storage-encryption-key".owner = "authelia-main";
  authelia.storageEncryptionKeyFile = config.sops.secrets."authelia/storage-encryption-key".path;
  sops.secrets."authelia/smtp-password".owner = "authelia-main";
  authelia.smtpPasswordFile = config.sops.secrets."authelia/smtp-password".path;

  ntfy.enable = true;
  ntfy.domainName = "notify.codecaptured.com";

  headscale.enable = true;
  headscale.subDomainName = "net";
  headscale.baseDomainName = "codecaptured.com";

  sops.secrets."headscale/oidc-secret".owner = "headscale";
  headscale.oidcSecretFile = config.sops.secrets."headscale/oidc-secret".path;

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
