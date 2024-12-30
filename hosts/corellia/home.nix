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

  gnome.enable = true;
  gnome-extensions.enable = true;

  # Common modules

  git.enable = true;
  cli-tools.enable = true;

  # Other config

  home.packages = with pkgs; [
    cargo
    darktable
    discord
    element-desktop
    gcc
    gimp
    inkscape
    localsend
    nextcloud-client
    nixpkgs-fmt
    nodejs_23
    protonvpn-gui
    rustc
    silverbullet
    ungoogled-chromium
    vlc
    vscode.fhs
    yarn
  ];

  programs = {
    firefox = {
      enable = true;
    };
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  # Workaround for nextcloud not starting up properly
  # https://discourse.nixos.org/t/nextcloud-client-does-not-auto-start-in-gnome3/46492/7
  systemd.user.services.nextcloud-client = {
    Unit = {
      After = pkgs.lib.mkForce "graphical-session.target";
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
