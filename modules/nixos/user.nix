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

    user.hashedPasswordFile = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    users = {
      # This prevents using normal bash commands to create/modify users
      mutableUsers = false;
      users.${cfg.name} = {
        isNormalUser = true;
        hashedPasswordFile = cfg.hashedPasswordFile;
        description = "main user";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.bash;
        openssh.authorizedKeys.keyFiles = [
          ../../modules/nixos/ssh-keys/mandalore/id_rsa.pub
          ../../modules/nixos/ssh-keys/corellia/id_rsa.pub
        ];
      };
    };
  };
}
