{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.homepage;
in
{
  options = {
    homepage.enable = lib.mkEnableOption "enable homepage module";

    homepage.domainName = lib.mkOption { type = lib.types.str; };
    homepage.certHostDomainName = lib.mkOption { type = lib.types.str; };

    homepage.port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
    };
  };

  config = lib.mkIf cfg.enable {

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domainName}" = {
        enableAuthelia = true;
        forceSSL = true;
        useACMEHost = cfg.certHostDomainName;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
        };
      };
    };

    services.homepage-dashboard = {
      enable = true;
      allowedHosts = cfg.domainName;
      settings = {
        title = "Start Page";
        background = {
          image = "https://science.nasa.gov/wp-content/uploads/2023/06/webb-flickr-52259221868-30e1c78f0c-4k-jpg.webp";
          blur = "sm";
          opacity = "30";
        };
      };
      widgets = [
        {
          greeting = {
            text_size = "4xl";
            text = "Hello there";
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
            focus = true;
          };
        }
        {
          openmeteo = {
            units = "imperial";
            cache = "5"; # Time in minutes to cache API responses, to stay within limits
          };
        }
        {
          resources = {
            cpu = true;
            memory = true;
            network = true;
          };
        }
      ];
      services = [
        {
          "Common Services" = [
            {
              "Cloud" = {
                description = "Store files and images";
                href = "https://cloud.internal.codecaptured.com";
                siteMonitor = "https://cloud.internal.codecaptured.com";
                icon = "sh-nextcloud";
              };
            }
            {
              "Recipes" = {
                description = "Recipes and Ingredients";
                href = "https://recipes.internal.codecaptured.com";
                siteMonitor = "https://recipes.internal.codecaptured.com";
                icon = "sh-mealie";
              };
            }
            {
              "Media" = {
                description = "Movies, Shows, Music";
                href = "https://jellyfin.internal.codecaptured.com";
                siteMonitor = "https://jellyfin.internal.codecaptured.com";
                icon = "sh-jellyfin";
              };
            }
            {
              "Books" = {
                description = "ebook library";
                href = "https://books.internal.codecaptured.com";
                siteMonitor = "https://books.internal.codecaptured.com";
                icon = "sh-autocaliweb";
              };
            }
            {
              "Home Assistant" = {
                description = "Home management and monitoring";
                href = "https://home.internal.codecaptured.com/auth/oidc/welcome";
                siteMonitor = "https://home.internal.codecaptured.com/";
                icon = "sh-home-assistant";
              };
            }
            {
              "FoundryVTT" = {
                description = "Recipes and Ingredients";
                href = "https://vtt.codecaptured.com";
                siteMonitor = "https://vtt.codecaptured.com";
                icon = "sh-foundry-virtual-tabletop";
              };
            }
          ];
        }
        {
          "Matthew's Services" = [
            {
              "SilverBullet" = {
                description = "Notes";
                href = "https://notes.internal.codecaptured.com/";
                siteMonitor = "https://notes.internal.codecaptured.com/";
                icon = "sh-silverbullet";
              };
            }
            {
              "Miniflux" = {
                description = "RSS Reader";
                href = "https://read.internal.codecaptured.com";
                siteMonitor = "https://read.internal.codecaptured.com";
                icon = "sh-miniflux";
              };
            }
            {
              "Forgejo" = {
                description = "Git Forge";
                href = "https://git.internal.codecaptured.com";
                siteMonitor = "https://git.internal.codecaptured.com";
                icon = "sh-forgejo";
              };
            }
            {
              "Internal Uptime Kuma" = {
                description = "Internal Status";
                href = "https://status.internal.codecaptured.com";
                siteMonitor = "https://status.internal.codecaptured.com";
                icon = "sh-uptime-kuma";
              };
            }
            {
              "External Uptime Kuma" = {
                description = "External Status";
                href = "https://status.codecaptured.com/";
                siteMonitor = "https://status.codecaptured.com/";
                icon = "sh-uptime-kuma-dark";
              };
            }
          ];
        }
      ];
      bookmarks = [
        {
          "Matthew's Sites" = [
            {
              Blog = [
                {
                  href = "https://codecaptured.com/";
                  icon = "mdi-web";
                }
              ];
            }
            {
              Resume = [
                {
                  href = "https://matthewbooe.com/";
                  icon = "mdi-badge-account";
                }
              ];
            }
          ];
        }
        {
          "Other Apps" = [
            {
              Chat = [
                {
                  href = "https://element.boowho.me/";
                  icon = "mdi-message-text";
                }
              ];
            }
            {
              Analytics = [
                {
                  href = "https://analytics.codecaptured.com";
                  icon = "mdi-chart-line";
                }
              ];
            }
            {
              Auth = [
                {
                  href = "https://auth.codecaptured.com";
                  icon = "mdi-shield-key";
                }
              ];
            }
            {
              LDAP = [
                {
                  href = "https://ldap.codecaptured.com/";
                  icon = "mdi-account-key";
                }
              ];
            }
            {
              Notifications = [
                {
                  href = "https://notify.codecaptured.com/";
                  icon = "mdi-bell-ring";
                }
              ];
            }
            {
              Homepage = [
                {
                  href = "https://start.internal.codecaptured.com/";
                  icon = "mdi-source-commit-start";
                }
              ];
            }
          ];
        }
        {
          "Financial" = [
            {
              Chase = [
                {
                  href = "https://chase.com/";
                  icon = "mdi-piggy-bank";
                }
              ];
            }
            {
              Ally = [
                {
                  href = "https://ally.com";
                  icon = "mdi-safe";
                }
              ];
            }
            {
              PayPal = [
                {
                  href = "https://paypal.com/us/home";
                  icon = "mdi-credit-card-wireless";
                }
              ];
            }
            {
              Fidelity = [
                {
                  href = "https://fidelity.com/";
                  icon = "mdi-chart-line";
                }
              ];
            }
            {
              Discover = [
                {
                  href = "https://discover.com/";
                  icon = "mdi-credit-card";
                }
              ];
            }
            {
              SoundCU = [
                {
                  href = "https://soundcuonline.com/dbank/live/app/home";
                  icon = "mdi-cash-multiple";
                }
              ];
            }
            {
              TreasuryDirect = [
                {
                  href = "https://treasurydirect.gov";
                  icon = "mdi-bank";
                }
              ];
            }
          ];
        }
      ];

    };
  };
}
