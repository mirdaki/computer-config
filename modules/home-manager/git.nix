{ lib, config, ... }:

let
  cfg = config.git;
in
{
  options = {
    git.enable = lib.mkEnableOption "enable git module";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "mirdaki";
      userEmail = "mirdaki@users.noreply.github.com";
      extraConfig = {
        push = {
          autoSetupRemote = true;
        };
      };
    };
  };
}
