{
  config,
  lib,
  pkgs,
  ...
}:

let
  primaryUser = "matthew";
  baseDomainName = "codecaptured.com";
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

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "taris";
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
  uptime-kuma.domainName = "status.${baseDomainName}";

  lldap.enable = true;
  lldap.domainName = "ldap.${baseDomainName}";
  lldap.httpUrl = "https://ldap.${baseDomainName}";
  lldap.ldapBaseDN = "dc=codecaptured,dc=com";

  sops.secrets."lldap/jwt-secret".owner = "lldap";
  lldap.jwtSecretFile = config.sops.secrets."lldap/jwt-secret".path;
  sops.secrets."lldap/ldap-user-pass".owner = "lldap";
  lldap.ldapUserPassFile = config.sops.secrets."lldap/ldap-user-pass".path;
  sops.secrets."lldap/key-seed".owner = "lldap";
  lldap.keySeedFile = config.sops.secrets."lldap/key-seed".path;

  authelia.enable = true;
  authelia.subDomainName = "auth";
  authelia.baseDomainName = baseDomainName;
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
  ntfy.domainName = "notify.${baseDomainName}";

  headscale.enable = true;
  headscale.subDomainName = "net";
  headscale.baseDomainName = baseDomainName;

  sops.secrets."headscale/oidc-secret".owner = "headscale";
  headscale.oidcSecretFile = config.sops.secrets."headscale/oidc-secret".path;

  tailscale.enable = true;
  tailscale.domainName = "net.${baseDomainName}";

  sops.secrets."tailscale/auth-key".owner = "tailscale";
  tailscale.authKeyFile = config.sops.secrets."tailscale/auth-key".path;

  foundryvtt-router.enable = false;
  foundryvtt-router.domainName = "vtt.${baseDomainName}";
  foundryvtt-router.proxyPass = "mandalore.contact-taris-testuser.${baseDomainName}:30000";

  # TODO: Will move to internal server
  namecheap-private-cert.enable = false;
  namecheap-private-cert.domainName = "internal.${baseDomainName}";

  sops.secrets.namecheap-credentials = {
    sopsFile = ./secrets/namecheap-credentials.txt;
    format = "binary";
  };
  sops.secrets."namecheap-credentials".owner = "acme";
  namecheap-private-cert.credentialsFile = config.sops.secrets."namecheap-credentials".path;

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
