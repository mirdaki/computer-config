# https://sqlite.org/backup.html
{ config, pkgs, ... }:

let
  cfg = config.sqliteBackup;
in
{
  options = {
    sqliteBackup.enable = lib.mkEnableOption "enable sqliteBackup module";

    sqliteBackup.databasePath = lib.mkOption { type = lib.types.str; };
    sqliteBackup.backupPath = lib.mkOption { type = lib.types.str; };
    sqliteBackup.backupTime = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sqliteBackup = {
      description = "Backup SQLite database";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec = "1d"; # Set to run every day
      };
      serviceConfig = {
        ExecStart = "${pkgs.coreutils}/bin/cp /path/to/your/database.db /path/to/backup/location/database_$(date +\\%Y-\\%m-\\%d).db";
        # You can use gzip or another compression tool if needed
        # ExecStartPost = "${pkgs.gzip}/bin/gzip /path/to/backup/location/database_$(date +\\%Y-\\%m-\\%d).db";
      };
    };

    # Enable the timer to run the backup periodically
    systemd.timers.sqliteBackup = {
      description = "SQLite backup timer";
      unitConfig = {
        OnBootSec = "10min"; # Start 10 minutes after boot
        OnUnitActiveSec = "1d"; # Run daily
      };
    };
  };
}
