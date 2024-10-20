{
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker;
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
