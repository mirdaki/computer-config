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
  filesPath = "/mnt/files";
  mediaPath = "/mnt/media";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  # Standard system settings

  # TODO: Can't write in subdirectories,
  fileSystems.${filesPath} = {
    device = "192.168.0.205:/mnt/data/files";
    fsType = "nfs";
    # Wait till access to mount
    options = [
      "x-systemd.automount"
      "noauto"
    ];
  };

  fileSystems.${mediaPath} = {
    device = "192.168.0.205:/mnt/data/media";
    fsType = "nfs";
    # Wait till access to mount
    options = [
      "x-systemd.automount"
      "noauto"
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable mounting Window's drive
  # TODO: Drive decryption doesn't seem to be working
  boot.supportedFilesystems = [ "ntfs" ];

  # Graphic hardware
  boot.kernelPackages = pkgs-unstable.linuxPackages_latest;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.new_feature;
  # Trying to fix the blank on resume/restart
  hardware.nvidia.modesetting.enable = true;
  powerManagement.enable = true;
  hardware.nvidia.powerManagement.enable = true;

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
  programs.yubikey-touch-detector = {
    enable = true;
  };

  # Custom modules

  common-config = {
    enable = true;
    hostName = hostName;
  };
  common-workstation-config.enable = true;

  user = {
    enable = true;
    name = primaryUser;
    enableSshKeys = true;
    shell = pkgs.nushell;
  };

  ssh.enable = true;
  ssh.allowUsername = primaryUser;

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
      "qwen3.8:27b-mtp-q4_K_M"
      "qwen3.8:27b-mtp-q8_0"
      "gemma4:31b-it-q4_K_M"
    ];
    package = pkgs-unstable.ollama-cuda;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "128000";
    };
  };
  services.open-webui.enable = true;

  # Set the power limit lower, since it's only a ~8% drop
  systemd.services.nvidia-power-limit = {
    description = "Set NVIDIA GPU power limit";
    wantedBy = [ "multi-user.target" ];
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
