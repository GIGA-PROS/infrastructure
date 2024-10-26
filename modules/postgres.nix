{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    barman
  ];

  # Postgres
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureDatabases = [
      "backend"
      "giga"
      "listmonk"
    ];
    ensureUsers = [
      {
        name = "backend";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
          createrole = true;
        };
      }
      {
        name = "giga";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
          createrole = true;
        };
      }
      {
        name = "listmonk";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
          createrole = true;
        };
      }
    ];
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root       postgres
      superuser_map      postgres   postgres
      superuser_map      deploy     postgres
      superuser_map      deploy     giga
      superuser_map      deploy     backend
      superuser_map      deploy     listmonk
      superuser_map      kanagawa   postgres
      superuser_map      kanagawa   giga
      superuser_map      kanagawa   backend
      superuser_map      kanagawa   listmonk
      superuser_map      benevides  postgres
      superuser_map      benevides  giga
      superuser_map      benevides  backend
      superuser_map      benevides  listmonk
      # Let other names login as themselves
      superuser_map      /^(.*)$    \1
    '';
    settings = {
      shared_preload_libraries = "pg_stat_statements";
      # pg_stat_statements config, nested attr sets need to be
      # converted to strings, otherwise postgresql.conf fails
      # to be generated.
      compute_query_id = "on";
      "pg_stat_statements.max" = 10000;
      "pg_stat_statements.track" = "all";
    };
    extraPlugins = with pkgs.postgresql_16.pkgs; [
      periods
      repmgr
    ];
    initialScript = pkgs.writeText "init-sql-script" ''
      CREATE EXTENSION pg_stat_statements;
    '';
  };

  # PG Bouncer
  services.pgbouncer = {
    enable = true;
    databases = {
      backend = "host=localhost port=5432 dbname=backend auth_user=backend";
    };
    extraConfig = ''
      min_pool_size=5
      reserve_pool_size=5
      max_client_conn=400
    '';
    listenAddress = "*";
    listenPort = 6432;
  };

  # haproxy
  #services.haproxy = {
  #  enable = true;
  #};

  # keepalived
  services.keepalived = {
    enable = true;
  };

  # Add passsword at runtime
  # https://discourse.nixos.org/t/set-password-for-a-postgresql-user-from-a-file-agenix/41377/8
  systemd.services."postgresql-db-setup" = {
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };
    after = ["postgresql.service"];
    path = with pkgs; [ postgresql_16 replace-secret];
    serviceConfig = {
      RuntimeDirectory = "postgresql-setup";           
      RuntimeDirectoryMode = "700";
    };
    script = ''
      # set bash options for early fail and error output
      set -o errexit -o pipefail -o nounset -o errtrace -o xtrace
      shopt -s inherit_errexit
      # Copy SQL template into temporary folder. The value of RuntimeDirectory is written into                 
      # environment variable RUNTIME_DIRECTORY by systemd.
      install --mode 600 ${./postgresql_init_template.sql} ''$RUNTIME_DIRECTORY/init.sql
      # fill SQL template with passwords
      ${pkgs.replace-secret}/bin/replace-secret @BACKEND_USER_PASSWORD@  ${config.age.secrets.pg_master_password.path} ''$RUNTIME_DIRECTORY/init.sql
      ${pkgs.replace-secret}/bin/replace-secret @GIGA_ADMIN_PASSWORD@ ${config.age.secrets.pg_master_password.path} ''$RUNTIME_DIRECTORY/init.sql
      ${pkgs.replace-secret}/bin/replace-secret @LISTMONK_USER_PASSWORD@  ${config.age.secrets.pg_master_password.path} ''$RUNTIME_DIRECTORY/init.sql
      # run filled SQL template
      psql postgres --file "''$RUNTIME_DIRECTORY/init.sql"
    '';
  };
}
