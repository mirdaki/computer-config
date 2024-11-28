# The authelia lldap user must be made manually before this runs. That user must have be in "lldap_password_manager" group

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.authelia;
in
{
  options = {
    authelia.enable = lib.mkEnableOption "enable authelia module";
    authelia.subDomainName = lib.mkOption { type = lib.types.str; };
    authelia.baseDomainName = lib.mkOption { type = lib.types.str; };
    authelia.ldapBaseDN = lib.mkOption { type = lib.types.str; };
    authelia.smtpUsername = lib.mkOption { type = lib.types.str; };

    authelia.jwtSecretFile = lib.mkOption { type = lib.types.str; };
    authelia.lldapPasswordFile = lib.mkOption { type = lib.types.str; };
    authelia.oidcHmacSecretFile = lib.mkOption { type = lib.types.str; };
    authelia.oidcIssuerPrivateKeyFile = lib.mkOption { type = lib.types.str; };
    authelia.sessionSecretFile = lib.mkOption { type = lib.types.str; };
    authelia.storageEncryptionKeyFile = lib.mkOption { type = lib.types.str; };
    authelia.smtpPasswordFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            extraConfig = ''
              ## Headers
              proxy_set_header Host $host;
              proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Host $http_host;
              proxy_set_header X-Forwarded-Uri $request_uri;
              proxy_set_header X-Forwarded-Ssl on;
              proxy_set_header X-Forwarded-For $remote_addr;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header Connection "";

              ## Basic Proxy Configuration
              client_body_buffer_size 128k;
              proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
              proxy_redirect  http://  $scheme://;
              proxy_http_version 1.1;
              proxy_cache_bypass $cookie_session;
              proxy_no_cache $cookie_session;
              proxy_buffers 64 256k;

              ## Trusted Proxies Configuration
              ## Please read the following documentation before configuring this:
              ##     https://www.authelia.com/integration/proxies/nginx/#trusted-proxies
              # set_real_ip_from 10.0.0.0/8;
              # set_real_ip_from 172.16.0.0/12;
              # set_real_ip_from 192.168.0.0/16;
              # set_real_ip_from fc00::/7;
              real_ip_header X-Forwarded-For;
              real_ip_recursive on;

              ## Advanced Proxy Configuration
              send_timeout 5m;
              proxy_read_timeout 360;
              proxy_send_timeout 360;
              proxy_connect_timeout 360;
            '';
            proxyPass = "http://127.0.0.1:9091";
          };
          locations."/api/verify" = {
            proxyPass = "http://127.0.0.1:9091";
          };
        };
      };

      authelia.instances.main = {
        enable = true;
        settings = {
          theme = "auto";
          log.level = "debug";
          password_policy.zxcvbn.enabled = true;
          session.domain = cfg.baseDomainName;

          authentication_backend.ldap = {
            implementation = "custom";
            url = "ldap://localhost:3890";
            base_dn = cfg.ldapBaseDN;
            users_filter = "(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))";
            groups_filter = "(member={dn})";
            user = "uid=authelia,ou=people,${cfg.ldapBaseDN}";
          };

          access_control = {
            default_policy = "deny";
            # More specific to less specific. First matching rule wins
            rules = [
              {
                domain = "net.${cfg.baseDomainName}";
                policy = "two_factor";
                subject = [ "group:private_network" ];
              }
              {
                domain = "*.internal.${cfg.baseDomainName}";
                policy = "two_factor";
                subject = [ "group:internal_common" ];
              }
              {
                domain = "*.${cfg.baseDomainName}";
                policy = "one_factor";
              }
            ];
          };

          storage.postgres = {
            host = "/run/postgresql";
            port = 5432;
            database = "authelia-main";
            username = "authelia-main";
            password = "authelia-main";
          };

          notifier.smtp = {
            username = cfg.smtpUsername;
            sender = "auth@${cfg.baseDomainName}";
            host = "smtp.gmail.com";
            port = "587";
          };
        };

        secrets = {
          jwtSecretFile = cfg.jwtSecretFile;
          oidcHmacSecretFile = cfg.oidcHmacSecretFile;
          oidcIssuerPrivateKeyFile = cfg.oidcIssuerPrivateKeyFile;
          sessionSecretFile = cfg.sessionSecretFile;
          storageEncryptionKeyFile = cfg.storageEncryptionKeyFile;
        };

        environmentVariables = {
          AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = cfg.lldapPasswordFile;
          AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = cfg.smtpPasswordFile;
        };
      };

      postgresql = {
        ensureDatabases = [ "authelia-main" ];
        ensureUsers = [
          {
            name = "authelia-main";
            ensureDBOwnership = true;
          }
        ];
      };
    };

    systemd.services.authelia-main = {
      requires = [
        "postgresql.service"
        "lldap.service"
      ];
      after = [
        "postgresql.service"
        "lldap.service"
      ];
    };
  };
}