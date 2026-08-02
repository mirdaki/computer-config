{
  config,
  pkgs,
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
    darktable
    discord
    element-desktop
    gimp
    gnome-system-monitor
    inkscape
    libreoffice
    localsend
    nixfmt
    protonvpn-gui
    prusa-slicer
    steam
    ungoogled-chromium
    vlc
    vscode.fhs
  ];

  programs = {
    firefox = {
      enable = true;
    };

    zed-editor = {
      enable = true;
    };

    opencode = {
      enable = true;
      settings = {
        model = "ollama/qwen3.6:27b-q4_K_M";
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama (local)";
            options = {
              baseURL = "http://localhost:11434/v1";
            };
            models = {
              "qwen3.6:27b-q4_K_M" = {
                name = "qwen3.6:27b";
              };
              "qwen3.6:27b-mtp-q8_0" = {
                name = "qwen3.6:27b-mtp";
              };
              # "qwen3.6:35b-a3b" = {
              #   name = "qwen3.6:35b-a3b-q4_K_M";
              # };
              "gemma4:31b-it-q4_K_M" = {
                name = "gemma4:31b";
              };
              # "gemma4:26b-a4b-it-q4_K_M" = {
              #   name = "gemma4:26b";
              # };
            };
          };
        };
      };
    };
  };

  services = {
    # TODO: Systray seems to have permission issues, needs tweaking
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

  # Custom modules
  git.enable = true;
  cli-tools.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.
}
