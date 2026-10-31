# TODO: Need to re-look at all this, https://github.com/drduh/YubiKey-Guide
{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.git;
in
{
  options = {
    gpg.enable = lib.mkEnableOption "enable gpg module";
  };

  config = lib.mkIf cfg.enable {

    programs.gpg = {
      enable = true;
      scdaemonSettings = {
        disable-ccid = true;
      };
      settings = {
        # Replace with your own Subkeys KeyID `gpg --list-keys --keyid-format LONG`
        default-key = "0x6D73CF87592E8307";
        trusted-key = "0x6D73CF87592E8307";
        # https://github.com/drduh/YubiKey-Guide/blob/master/config/gpg.conf
        # https://www.gnupg.org/documentation/manuals/gnupg/GPG-Options.html
        # 'gpg --version' to get capabilities
        # Use AES256, 192, or 128 as cipher
        personal-cipher-preferences = "AES256 AES192 AES";
        # Use SHA512, 384, or 256 as digest
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        # Use ZLIB, BZIP2, ZIP, or no compression
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        # Default preferences for new keys
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        # SHA512 as digest to sign keys
        cert-digest-algo = "SHA512";
        # SHA512 as digest for symmetric ops
        s2k-digest-algo = "SHA512";
        # AES256 as cipher for symmetric ops
        s2k-cipher-algo = "AES256";
        # UTF-8 support for compatibility
        charset = "utf-8";
        # No comments in messages
        no-comments = "";
        # No version in output
        no-emit-version = "";
        # Disable banner
        no-greeting = "";
        # Long key id format
        keyid-format = "0xlong";
        # Display UID validity
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        # Display all keys and their fingerprints
        with-fingerprint = "";
        # Display key origins and updates
        #with-key-origin
        # Cross-certify subkeys are present and valid
        require-cross-certification = "";
        # Enforce memory locking to avoid accidentally swapping GPG memory to disk
        require-secmem = "";
        # Disable caching of passphrase for symmetrical ops
        no-symkey-cache = "";
        # Output ASCII instead of binary
        armor = "";
        # Enable smartcard
        use-agent = "";
        # Disable recipient key ID in messages (WARNING: breaks Mailvelope)
        throw-keyids = "";
        # Keyserver URL
        keyserver = "hkps://keys.openpgp.org";
      };
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
      enableNushellIntegration = true;
      enableSshSupport = true;
      defaultCacheTtl = 60;
      maxCacheTtl = 120;
      sshKeys = [
        # Keygrip of Authenticate Subkey
        # gpg --list-secret-keys --with-keygrip --keyid-format LONG
        "022B3084AC2D196F8567B30E684BBA3415ACC99D"
      ];
      extraConfig = ''
        # https://github.com/drduh/YubiKey-Guide/blob/master/config/gpg-agent.conf
        # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
        ttyname $GPG_TTY
        # Optional: Allow the agent to listen on the socket
          # (Usually default, but good to verify)
          allow-loopback-pinentry
      '';
    };
  };
}
