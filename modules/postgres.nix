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

  # Add passsword after pg starts
  # https://discourse.nixos.org/t/assign-password-to-postgres-user-declaratively/9726/3
  systemd.services.postgresql.postStart = let
    password_file_path = config.age.secrets.pg_master_password.path;
  in ''
    $PSQL -tA <<'EOF'
      DO $$
      DECLARE password TEXT;
      BEGIN
        password := trim(both from replace(pg_read_file('${password_file_path}'), E'\n', '''));
        EXECUTE format('ALTER USER backend WITH PASSWORD '''%s''';', password);
        EXECUTE format('ALTER USER giga WITH PASSWORD '''%s''';', password);
        EXECUTE format('ALTER USER listmonk WITH PASSWORD '''%s''';', password);
      END $$;
    EOF
  '';
}
