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
      settings = {
        user = {
          name = "mirdaki";
          email = "mirdaki@users.noreply.github.com";
        };
        push = {
          autoSetupRemote = true;
        };
      };
    };
  };
}
