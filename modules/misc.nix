{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    vim

    # NodeJs
    nodejs
    yarn
    pm2

    # Sendportal
    #php
    #phpPackages.composer

    # Backend
    dotnet-sdk_8

    # LLM
    ollama
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Keycloak
  #services.keycloak.enable = true;

  # Redis
  services.redis = {
    servers."kanagawa".enable = true;
  };
}
