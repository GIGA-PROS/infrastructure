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

    # Backend
    dotnet-sdk_8
  ];

  # Optional: Set environment variables (e.g., AWS credentials)
  # Replace with your actual AWS credentials or use a profile
  AWS_ACCESS_KEY_ID="your-access-key-id";
  AWS_SECRET_ACCESS_KEY="your-secret-access-key";

  # Optional: Start Redis and PostgreSQL within the nix-shell environment
  shellHook = ''
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
  '';
}