{ pkgs, config, modulesPath, ... }:

{
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

    virtualHosts."crm.gigapros.io" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3060";
        proxyWebsockets = true;
        extraConfig =
          "proxy_ssl_server_name on;" +
          "proxy_pass_header Authorization;";
      };
    };
  };
}
