{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

let
  hostName = "mandalore";
  primaryUser = "matthew";
  baseDomainName = "codecaptured.com";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  # Standard system settings

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Hardware
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  # Trying to fix the blank on resume/restart
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  # May help if FFmpeg/VAAPI/QSV init fails (esp. on Arc with i915):
  hardware.enableRedistributableFirmware = true;

  # Resolve a Cosmic and Gnome bug https://discourse.nixos.org/t/graphics-glitches-in-gnome-apps/73442/2
  hardware.graphics.package = pkgs-unstable.mesa;

  # Custom modules

  common-config = {
    enable = true;
    hostName = hostName;
  };
  common-workstation-config.enable = true;

  user = {
    enable = true;
    name = primaryUser;
    shell = pkgs.nushell;
  };

  plymouth.enable = true;

  flatpak = {
    enable = true;
    flatpakStore = pkgs.cosmic-store;
  };

  # Specific package settings

  programs.steam.enable = true;

  nixpkgs.config.allowUnfreePredicate =
    pkgs-unstable:
    builtins.elem (lib.getName pkgs-unstable) [
      # Add additional package names here
      "ollama-cuda"
    ];

  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [
      "qwen3.6:27b-q4_K_M"
      "qwen3.6:27b-mtp-q8_0"
      # "qwen3.6:35b-a3b-q4_K_M"
      "gemma4:31b-it-q4_K_M"
      # "gemma4:26b-a4b-it-q4_K_M"
    ];
    package = pkgs-unstable.ollama-cuda;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "64000";
    };
  };
  services.open-webui.enable = true;

  # Set the power limit lower, since it's only a ~8% drop
  systemd.services.nvidia-power-limit = {
    description = "Set NVIDIA GPU power limit";
    wantedBy = [ "multi-user.target" ];
    requires = [ "nvidia-persistenced.service" ];
    after = [ "nvidia-persistenced.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' config.hardware.nvidia.package "nvidia-smi"} -pl 250";
    };
  };

  services = {
    tailscale = {
      enable = true;
      extraUpFlags = [ "--login-server=https://net.${baseDomainName}" ];
      # Allows the systray to funciton
      extraSetFlags = [ "--operator=${primaryUser}" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
