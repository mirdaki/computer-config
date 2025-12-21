{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  primaryUser = "matthew";
  baseDomainName = "codecaptured.com";
  internalDomainName = "internal.${baseDomainName}";
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

  # System

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "corellia";
  time.timeZone = "America/Los_Angeles";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-d4f044d7-81b1-4abe-a993-ed87bec2cb7d".device =
    "/dev/disk/by-uuid/d4f044d7-81b1-4abe-a993-ed87bec2cb7d";

  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Software updates
  system.autoUpgrade = {
    enable = true;
    flake = "../../flake.nix";
    flags = [
      "-L" # print build logs
    ];
    runGarbageCollection = true;
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  # Was running into issues with the download buffer being exceeded
  nix.settings.download-buffer-size = 524288000; # 500MB

  # Other config

  sops.defaultSopsFile = ./secrets/secret.yaml;
  sops.age.keyFile = "/home/${primaryUser}/.config/sops/age/keys.txt";

  users.users.${primaryUser} = {
    isNormalUser = true;
    description = primaryUser;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.nushell;

    packages = with pkgs; [
      # Setup flaktpak in software center
      flatpak
      gnome-software
    ];
  };

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  services.fwupd.enable = true;
  programs.bash.completion.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Software

  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.nixfmt
    pkgs-unstable.ghostty
  ];

  tailscale = {
    enable = true;
    domainName = "net.${baseDomainName}";
    authKeyFile = config.sops.secrets."tailscale/auth-key".path;
  };
  sops.secrets."tailscale/auth-key".owner = config.users.users.tailscale.name;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
