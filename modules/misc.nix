{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    neovim
    htop

    # NodeJs
    nodejs
    yarn
    pm2

    # Sendportal
    php
    phpPackages.composer

    # Backend
    dotnet-sdk_8
  ];

  # Keycloak
  #services.keycloak.enable = true;

  # Caddy
  services.caddy = {
    enable = true;
    #virtualHosts."localhost".extraConfig = ''
    #  :80 {
    #    reverse_proxy localhost:3000
    #  }
    #'';
    virtualHosts."localhost".extraConfig = ''
      respond "Hello, world!"
    '';
  };

  # Redis
  services.redis = {
    servers."kanagawa".enable = true;
  };

  services.getty.autologinUser = "root";

  # Networking
  networking.firewall.allowedTCPPorts = [
    80
    22
  ];
  services.openssh.enable = true;

  # Nix configuration
  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = [ "@wheel" ];
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # Clean up /nix/store/ after a week
    gc = {
      automatic = true;
      dates = "weekly UTC";
      options = "--delete-older-than 7d";
    };
  };

  system.stateVersion = "24.05";
}
