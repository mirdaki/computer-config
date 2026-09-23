{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [ ../../modules/home-manager/common.nix ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "matthew";
  home.homeDirectory = "/home/matthew";

  # Packages
  home.packages = with pkgs; [
    baobab
    blender
    darktable
    discord
    element-desktop
    freecad
    fresh-editor
    gimp
    gnome-disk-utility
    gnome-screenshot
    gnupg
    harper
    hunspell
    hunspellDicts.en-us
    inkscape
    inputs.zen-browser.packages.${pkgs.system}.default
    libreoffice
    lm_sensors
    localsend
    loupe
    mission-center
    nixfmt
    nixos-option
    papers
    proton-vpn
    prusa-slicer
    resources
    showtime
    ungoogled-chromium
    vlc
    vscode.fhs
    yubikey-manager
  ];

  programs = {
    firefox = {
      enable = true;
      # Set because of a `home.stateVersion` is less than "26.05" migration
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };

    zed-editor = {
      enable = true;
      userSettings = {
        # Enable debugging on NixOS
        dap = {
          CodeLLDB = {
            binary = lib.getExe' pkgs.lldb "lldb-dap";
          };
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableNushellIntegration = true;
    };

    opencode = {
      enable = true;
      settings = {
        model = "ollama/qwen3.8:27b-mtp-q4_K_M";
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama (local)";
            options = {
              baseURL = "http://localhost:11434/v1";
            };
            models = {
              "qwen3.8:27b-mtp-q4_K_M" = {
                variants = {
                  "qwen3.8:27b-mtp-reason" = {
                    reasoningEffort = "xhigh";
                  };
                  "qwen3.8:27b-mtp" = {
                    reasoningEffort = "medium";
                  };
                };
              };
              "gemma4:31b-it-q4_K_M" = {
                name = "gemma4:31b";
              };
            };
          };
        };
      };
    };
  };

  services = {
    tailscale-systray.enable = true;

    nextcloud-client = {
      enable = true;
    };
  };

  # Workaround for nextcloud not starting up properly with startInBackground
  # https://discourse.nixos.org/t/nextcloud-client-does-not-auto-start-in-gnome3/46492/7
  systemd.user.services.nextcloud-client = {
    Unit = {
      After = pkgs.lib.mkForce "graphical-session.target";
    };
  };

  xdg.autostart = {
    enable = true;
    entries = [
      (pkgs.writeText "protonvpn.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=ProtonVPN
        Exec=${pkgs.proton-vpn}/bin/protonvpn-app
        X-GNOME-Autostart-enabled=true
      '')
      (pkgs.writeText "element.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=Element
        Exec=${pkgs.element-desktop}/bin/element-desktop
      '')
      (pkgs.writeText "discord.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=Discord
        Exec=${pkgs.discord}/bin/discord
      '')
    ];
  };

  # Custom modules
  git = {
    enable = true;
    gpgKeyId = "6D73CF87592E8307";
  };
  cli-tools.enable = true;
  gpg.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.
}
