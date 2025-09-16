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

  # Was running into buffer warnings, bumped to 500MB
  # https://github.com/NixOS/nix/issues/11728
  nix.settings.download-buffer-size = 524288000;

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

  vscode-remote-ssh.enable = true;

  security.enable = true;

  firewall.enable = true;

  # Other config

  programs.bash.completion.enable = true;

  linode.enable = true;

  # Services

  acme.enable = true;
  acme.email = "contact+letsencrypt.org@boowho.me";

  nginx-recommended.enable = true;

  postgresql.enable = true;

  lldap = {
    enable = true;
    domainName = "ldap.${baseDomainName}";
    ldapBaseDN = "dc=codecaptured,dc=com";

    jwtSecretFile = config.sops.secrets."lldap/jwt-secret".path;
    ldapUserPassFile = config.sops.secrets."lldap/ldap-user-pass".path;
  };
  sops.secrets."lldap/jwt-secret".owner = "lldap";
  sops.secrets."lldap/ldap-user-pass".owner = "lldap";

  authelia = {
    enable = true;
    subDomainName = "auth";
    baseDomainName = baseDomainName;
    ldapBaseDN = "dc=codecaptured,dc=com";
    smtpUsername = "codecaptured@gmail.com";

    jwtSecretFile = config.sops.secrets."authelia/jwt-secret".path;
    lldapPasswordFile = config.sops.secrets."authelia/lldap-password".path;
    oidcHmacSecretFile = config.sops.secrets."authelia/oidc-hmac-secret".path;
    oidcIssuerPrivateKeyFile = config.sops.secrets."authelia-oidc-issuer-private-key".path;
    sessionSecretFile = config.sops.secrets."authelia/session-secret".path;
    storageEncryptionKeyFile = config.sops.secrets."authelia/storage-encryption-key".path;
    smtpPasswordFile = config.sops.secrets."authelia/smtp-password".path;
  };
  sops.secrets."authelia/jwt-secret".owner = "authelia-main";
  sops.secrets."authelia/lldap-password".owner = "authelia-main";
  sops.secrets."authelia/oidc-hmac-secret".owner = "authelia-main";
  sops.secrets."authelia-oidc-issuer-private-key".owner = "authelia-main";
  sops.secrets."authelia/session-secret".owner = "authelia-main";
  sops.secrets."authelia/storage-encryption-key".owner = "authelia-main";
  sops.secrets."authelia/smtp-password".owner = "authelia-main";
  sops.secrets.authelia-oidc-issuer-private-key = {
    sopsFile = ./secrets/oidc-issuer-private-key.pem;
    format = "binary";
  };

  headscale = {
    enable = true;
    subDomainName = "net";
    baseDomainName = baseDomainName;

    oidcSecretFile = config.sops.secrets."headscale/oidc-secret".path;
  };
  sops.secrets."headscale/oidc-secret".owner = "headscale";

  tailscale = {
    enable = true;
    domainName = "net.${baseDomainName}";

    authKeyFile = config.sops.secrets."tailscale/auth-key".path;
  };
  sops.secrets."tailscale/auth-key".owner = "tailscale";

  ntfy = {
    enable = true;
    domainName = "notify.${baseDomainName}";
  };

  uptime-kuma = {
    enable = true;
    subDomainName = "status";
    baseDomainName = baseDomainName;
  };

  # Support for internal services

  nextcloud-oidc = {
    enable = true;
    domainName = "cloud.internal.${baseDomainName}";
  };

  miniflux-oidc = {
    enable = true;
    domainName = "reader.internal.${baseDomainName}";
  };

  jellyfin-oidc = {
    enable = true;
    domainName = "jellyfin.internal.${baseDomainName}";
  };

  mealie-oidc = {
    enable = true;
    domainName = "recipes.internal.${baseDomainName}";
  };

  home-assistant-oidc = {
    enable = true;
    domainName = "home.internal.${baseDomainName}";
  };

  foundryvtt-router = {
    enable = true;
    domainName = "vtt.${baseDomainName}";
    proxyPass = "bespin.internal.${baseDomainName}:30000";
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
