# Manual page with instructions https://nixos.org/manual/nixos/stable/#module-services-postgres-upgrading
# sudo su -
# upgrade-pg-cluster --jobs 6
# exit
# rebuild # with new postgres version
# sudo -u postgres vacuumdb --all --analyze-in-stages
# Running this script will delete the old cluster's data files: ./delete_old_cluster.sh (?)

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.postgresql-upgrade;
  postgresCfg = config.services.postgresql;

  # XXX specify the postgresql package you'd like to upgrade to.
  # Do not forget to list the extensions you need.
  newPostgres = pkgs.postgresql_16.withPackages (pp: [
    # pp.plv8
  ]);
in
{
  options = {
    postgresql-upgrade.enable = lib.mkEnableOption "enable postgresql-upgrade module";

    postgresql-upgrade.dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/postgresql";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      (pkgs.writeScriptBin "upgrade-pg-cluster" ''
        set -eux
        # XXX it's perhaps advisable to stop all services that depend on postgresql
        systemctl stop postgresql

        # Make this directory modular
        export NEWDATA="${cfg.dataDir}/${newPostgres.psqlSchema}"
        export NEWBIN="${newPostgres}/bin"

        export OLDDATA="${postgresCfg.dataDir}"
        export OLDBIN="${postgresCfg.finalPackage}/bin"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs postgresCfg.initdbArgs}

        sudo -u postgres "$NEWBIN/pg_upgrade" \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
          "$@"
      '')
    ];
  };
}
