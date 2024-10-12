{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [ "/dev/xvda" ];

  networking.hostName = "nixos-ec2";
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Timezone and locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Users and SSH settings
  users.users.ec2-user = {
    isNormalUser = true;
    home = "/home/ec2-user";
    shell = pkgs.bash;
    extraGroups = [ "wheel" "docker" ];
  };

  # Packages to be installed
  environment.systemPackages = with pkgs; [
    git
    docker
    docker-compose
    nodejs
    yarn
    pm2
    php
    composer
    postgresql_16
    redis
    dotnet-sdk_8
    caddy
  ];

  # Enable Docker service
  services.docker.enable = true;

  # Enable Caddy reverse proxy
  services.caddy = {
    enable = true;
    config = ''
      :80 {
        reverse_proxy localhost:3000
      }
    '';
  };

  # Enable PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    initialScript = ''
      CREATE USER ec2-user WITH PASSWORD 'password';
      CREATE DATABASE mydatabase OWNER ec2-user;
    '';
  };

  # Enable Redis
  services.redis = {
    enable = true;
  };

  # Enable PHP
  services.phpfpm = {
    enable = true;
    poolConfigs = {
      "www" = {
        listen = "/run/phpfpm-www.sock";
        user = "ec2-user";
        group = "nginx";
      };
    };
  };

  # Enable NVM for Node.js
  environment.shellInit = ''
    export NVM_DIR="$HOME/.nvm"
    [ -s "/nix/store/$(readlink /nix/var/nix/profiles/per-user/$USER/profile)/etc/profile.d/nvm.sh" ] && . "/nix/store/$(readlink /nix/var/nix/profiles/per-user/$USER/profile)/etc/profile.d/nvm.sh"
  '';

  # Ensure Docker starts on boot
  systemd.services.docker = {
    enable = true;
    startWhenNeeded = true;
  };
}
