{ lib, config, ... }:

let
  cfg = config.git;
in
{
  options = {
    git.enable = lib.mkEnableOption "enable git module";

    git.gpgKeyId = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Matthew Booe";
          email = "dev@boowho.me";
        };
        push = {
          autoSetupRemote = true;
        };
        pull = {
          rebase = false;
        };
      };
      signing = {
        format = "openpgp";
        key = cfg.gpgKeyId;
        # TODO: Need to think on if this makes sense for my workflow
        # signByDefault = true;
      };
    };
  };
}
