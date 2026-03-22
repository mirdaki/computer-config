{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.user;
in
{
  options = {
    user.enable = lib.mkEnableOption "enable user module";

    user.name = lib.mkOption { type = lib.types.str; };

    user.shell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bash;
    };

    user.hashedPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    user.enableSshKeys = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    user.extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      # False prevents using normal bash commands to create/modify users
      mutableUsers = (cfg.hashedPasswordFile == null);
      users.${cfg.name} = {
        isNormalUser = true;
        description = cfg.name;
        extraGroups = [
          "networkmanager"
          "wheel"
        ]
        ++ cfg.extraGroups;
        # Shell needs to be set here to automatically start, even though it's configured in home-manager
        shell = cfg.shell;
        openssh.authorizedKeys.keyFiles = lib.mkIf cfg.enableSshKeys [
          ../../modules/nixos/ssh-keys/mandalore/id_rsa.pub
          ../../modules/nixos/ssh-keys/corellia/id_rsa.pub
        ];
      }
      # This merges attribute sets
      // lib.optionalAttrs (cfg.hashedPasswordFile != null) {
        hashedPasswordFile = cfg.hashedPasswordFile;
      };
    };
  };
}
