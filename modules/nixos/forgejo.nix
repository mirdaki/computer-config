# Based on the config from here https://wiki.nixos.org/wiki/Forgejo
# With project info from here https://forgejo.org/docs/latest/admin/config-cheat-sheet/

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.forgejo;
in
{
  options = {
    forgejo.enable = lib.mkEnableOption "enable forgejo module";

    forgejo.subDomainName = lib.mkOption { type = lib.types.str; };
    forgejo.baseDomainName = lib.mkOption { type = lib.types.str; };
    forgejo.certHostDomainName = lib.mkOption { type = lib.types.str; };
    forgejo.authDomainName = lib.mkOption { type = lib.types.str; };
    forgejo.smtpEmail = lib.mkOption { type = lib.types.str; };

    forgejo.dataDir = lib.mkOption { type = lib.types.str; };

    forgejo.smtpPasswordFile = lib.mkOption { type = lib.types.str; };

    forgejo.runnerSecretFile = lib.mkOption { type = lib.types.str; };

    forgejo.user = lib.mkOption {
      type = lib.types.str;
      default = "forgejo";
    };

    forgejo.group = lib.mkOption {
      type = lib.types.str;
      default = "forgejo";
    };

    forgejo.port = lib.mkOption {
      type = lib.types.port;
      default = 9099;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = {
        enable = true;
        virtualHosts."${cfg.subDomainName}.${cfg.baseDomainName}" = {
          forceSSL = true;
          useACMEHost = cfg.certHostDomainName;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
          };
          extraConfig = ''
            client_max_body_size 512M;
          '';
        };
      };

      forgejo = {
        enable = true;
        database.type = "postgres";
        stateDir = cfg.dataDir;

        # Enable support for Git Large File Storage
        lfs.enable = true;

        settings = {
          server = {
            DOMAIN = "${cfg.subDomainName}.${cfg.baseDomainName}";
            # You need to specify this to remove the port from URLs in the web UI.
            ROOT_URL = "https://${cfg.subDomainName}.${cfg.baseDomainName}/";
            HTTP_PORT = cfg.port;

            DISABLE_SSH = true;
          };

          # Add support for actions, based on act: https://github.com/nektos/act
          actions = {
            ENABLED = true;
            DEFAULT_ACTIONS_URL = "github";
          };

          # You can send a test email from the web UI at:
          # Profile Picture > Site Administration > Configuration >  Mailer Configuration
          mailer = {
            ENABLED = true;
            SMTP_ADDR = "smtp.gmail.com";
            SMTP_PORT = "587";
            FROM = "forgejo@${cfg.baseDomainName}";
            USER = cfg.smtpEmail;
          };

          openid = {
            ENABLE_OPENID_SIGNIN = false;
            ENABLE_OPENID_SIGNUP = true;
            WHITELISTED_URIS = cfg.authDomainName;
          };

          service = {
            # You can temporarily allow registration to create an admin user.
            DISABLE_REGISTRATION = false;
            ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
            SHOW_REGISTRATION_BUTTON = false;
          };
        };

        secrets = {
          mailer.PASSWD = cfg.smtpPasswordFile;
        };
      };

      gitea-actions-runner = {
        package = pkgs.forgejo-runner;
        instances.default = {
          enable = true;
          name = "default-forgejo-runner";
          # To register a runners you will need to generate a token. https://forgejo.org/docs/latest/user/actions/#forgejo-runner
          # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
          tokenFile = cfg.runnerSecretFile;
          url = "https://${cfg.subDomainName}.${cfg.baseDomainName}/";
          labels = [
            "debian-latest:docker://debian:latest-backports"
            "nixos-latest:docker://nixos/nix"
          ];
          settings = { };
        };
      };
    };

    services.postgresql = {
      ensureDatabases = [ cfg.user ];
      ensureUsers = [
        {
          name = cfg.user;
          ensureDBOwnership = true;
        }
      ];
    };

  };
}
