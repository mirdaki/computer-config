{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.postgresql;
in
{
  options = {
    postgresql.enable = lib.mkEnableOption "enable postgresql module";

    postgresql.dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
    };

    postgresql.backupDataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/backup/postgresql";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      dataDir = cfg.dataDir;

      # Limit which system users can log in as which DB user
      # https://nixos.wiki/wiki/PostgreSQL#Harden_authentication
      identMap = ''
        # ArbitraryMapName systemUser DBUser
          superuser_map      root      postgres
          superuser_map      postgres  postgres
          # Let other names login as themselves
          superuser_map      /^(.*)$   \1
      '';
      # Limit what DB user can access which databases
      # https://nixos.wiki/wiki/PostgreSQL#Limit_Access
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method optional_ident_map
        local sameuser  all     peer        map=superuser_map
      '';
    };

    # Nightly database backups.
    services.postgresqlBackup = {
      enable = true;
      startAt = "*-*-* 23:00:00";
      location = cfg.backupDataDir;
    };
  };
}
