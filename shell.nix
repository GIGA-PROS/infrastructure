{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # List of packages to be installed in the local environment
  buildInputs = with pkgs; [
    # Infrastructure
    git
    awscli
    opentofu
    docker
    docker-compose
    postgresql_16
    redis
    caddy

    # Sendportal v2 - Specific
    php
    phpPackages.composer

    # Common
    nodejs
    yarn
    pm2
    keycloak

    # Backend
    dotnet-sdk_8
  ];

  # Optional: Set environment variables (e.g., AWS credentials)
  # Replace with your actual AWS credentials or use a profile
  AWS_ACCESS_KEY_ID="your-access-key-id";
  AWS_SECRET_ACCESS_KEY="your-secret-access-key";

  # Optional: Set FORCE_OVERWRITES variable
  FORCE_OVERWRITES = "true";  # Set the variable here

  # Optional: Start Redis and PostgreSQL within the nix-shell environment
  shellHook = ''

  # Export the variable for use in the shell
    export FORCE_OVERWRITES="${FORCE_OVERWRITES}"
    echo "Starting Redis and PostgreSQL inside Nix shell..."

    # Start Redis
    if ! pgrep redis-server > /dev/null; then
      echo "Starting Redis..."
      redis-server --daemonize yes
    fi

    # Start PostgreSQL
    if ! pgrep postgres > /dev/null; then
      echo "Initializing and starting PostgreSQL..."
      initdb $HOME/pgdata || echo "PostgreSQL already initialized"
      pg_ctl -D $HOME/pgdata -l logfile start
    fi

    # Set environment variable for Node.js version
    export NODE_VERSION="16" 

    # Sendportal (Email Marketing)
    if [ ! -d "sendportal-app" ] || [ "$FORCE_OVERWRITES" = "true" ]; then
      composer create-project --prefer-dist laravel/laravel sendportal-app
      cd sendportal-app
      composer require mettle/sendportal-core
      php artisan vendor:publish --provider="Sendportal\Base\SendportalBaseServiceProvider"
      php artisan migrate
      php artisan sp:install
      php artisan serve --port=4280
    else
      echo "Sendportal app already exists. Use FORCE_OVERWRITES=true to overwrite."
    fi
'';
}
