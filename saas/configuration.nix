{ modulesPath, pkgs,  ... }: {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  # Nix configuration
  nix.settings.trusted-users = [ "@wheel" ];
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  security.acme.defaults.email = "cadastro@gigapros.io";
  security.acme.acceptTerms = true;
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # other Nginx options

    virtualHosts."notion.gigapros.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3010";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;";
      };
    };

    virtualHosts."meet.gigapros.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3020";
        proxyWebsockets = true;
        extraConfig =
          "proxy_ssl_server_name on;" +
          "proxy_pass_header Authorization;";
      };
    };

    virtualHosts."post.gigapros.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3030";
        proxyWebsockets = true;
        extraConfig =
          "proxy_ssl_server_name on;" +
          "proxy_pass_header Authorization;";
      };
    };

    virtualHosts."newsletter.gigapros.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3040";
        proxyWebsockets = true;
        extraConfig =
          "proxy_ssl_server_name on;" +
          "proxy_pass_header Authorization;";
      };
    };

    virtualHosts."crm.gigapros.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3050";
        proxyWebsockets = true;
        extraConfig =
          "proxy_ssl_server_name on;" +
          "proxy_pass_header Authorization;";
      };
    };

    virtualHosts."edu.gigapros.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3050";
        proxyWebsockets = true;
        extraConfig =
          "proxy_ssl_server_name on;" +
          "proxy_pass_header Authorization;";
      };
    };
  };

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
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      dates = "weekly";
      enable = true;
      flags = [ "--all" ];
    };
  };
  security.sudo.wheelNeedsPassword = false;
  environment.systemPackages = with pkgs; [
    git
    vim
    docker-compose
    docker
    htop
  ];
  # Users
  users.users = {
    benevides = {
      isNormalUser = true;
      createHome = true;
      description = "Benevides";
      group = "users";
      shell = "/bin/sh";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKStRI4iiTc6nTPKc0SPjHq79psNR5q733InvuHFAT0BHIiKWmDHeLS5jCep/MMrKa1w9qCt3bAnJVyu33+oqISx/5PzDBikiBBtBD6irovJx9dVvkjWkQLcbZwcStUfn6HFjyWdUb1jZqzQMf3JWeIj3RgP8nKwDatHSVB0GkvSETBiJ+bfbGKK1bacusqfsiN3b2niytDgnWMtKB4tMgvGUn5AEqRBtI5zDrnPU1T7edDCjI32QLBln/HlcfAHz+avN4YsW7iTWu25N/MSOQwBrKHLEQviGq9/j3Wu1pzxV2n2m32uUATFEKLf3sLCdsOWm1r+HlsXOcukUZnRhLc9O2ZVoWtDHo72iOzVY6rlRBoHvoUxw6A8k/jZWb1ospvjOLsjZuAZaDSjcE6iM0nXQSdhgGPSgeCTofOgteYoovA4XlK4aNomuTI3OPLr9P9SLC0qJHidvLIGQYWyMiwdeDJESbY2PFUNCi5VffwEUPYh8sp3E8EwjGDvSCygu4fU7vqaOi3OEziwg2ff89CdVr7k606LYmRF3dR+12Cp6XBOgUoaz+OzGn0Sr9HXw3GiF9xH/e1PL6mHwUT2NARB/mI64uY9JAi0/hrwkQsiIx1tf63qUDz/je9gk53wP7/GfWNoIeEkRzCz0QkEnxcMEoLjbTk56JFkmP0fpHDQ== (none)"
      ];
    };

    kanagawa = {
      isNormalUser = true;
      createHome = true;
      description = "Kanagawa";
      group = "users";
      shell = "/bin/sh";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZudUl8jgFsOYouFL2jXFsADyDSKM0f8k/yCyVwlTMv2O3KTAN58OZcQP0NvaCE1xf0c8Z73sBDQE0LZcCuYvJv3Qfuiur2TOr0YgllnUz9XdkFWBNLykfcuOyo7Lvk0BQxXHJr2ADJVvfLRoaSpubYI40KYe2BJUXtwjUcLEUW8Pd9XknI59hCmgdJpWxotCWimGW5I+r8S5zEdTtMoJWMdDaAgzbw5AL+d227wTL0TKwA1LnCkAISgCCYcUGKG78Q8At1/gN/Q9Vl/v+CR9zYWiPgZihk2aK2LiYPPQbu5hhISyEnnJSIojDhZjCib+4Dt93bfKwMMKJxMF9XFeONINkecCyMOIIcfoGzRPoZNRyjc+TbHc84YuaizmJCHgD17dBnmxwZ75rMZHaKtGq4QJ+phP9bwP9oqAaTdDhFGcr1Ia4ozW2t1T3spDiVC3S5AxiwERLO15IDQwN8plJrIdR2lsQAs4dU3/uA5XEmcnPFVMy32fcKlUwJDMgGmM= mcosta@Marcoss-MacBook-Pro.local"
      ];
    };
  };  
  
}