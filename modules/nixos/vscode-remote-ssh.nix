{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.vscode-remote-ssh;
in
{
  options = {
    vscode-remote-ssh.enable = lib.mkEnableOption "enable vscode-remote-ssh module";
  };

  config = lib.mkIf cfg.enable {
    # This gets Remote SSH working with VSCode https://nixos.wiki/wiki/Visual_Studio_Code#nix-ld
    programs.nix-ld.enable = true;

    environment.systemPackages = with pkgs; [ nixfmt-rfc-style ];
  };
}
