{ config, pkgs, ... }:

{
  imports = [ ../../modules/home-manager/common.nix ];

  gnome.enable = true;

  git.enable = true;

  home.username = "matthew";
  home.homeDirectory = "/home/matthew";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nextcloud-client
    protonvpn-gui
    discord
    element-desktop
    silverbullet
    vlc
    nixpkgs-fmt
    vscode.fhs
    yarn
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  programs = {
    firefox = {
      enable = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
