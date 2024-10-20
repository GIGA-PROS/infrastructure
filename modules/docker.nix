{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ docker-compose ];
  users.users.deploy.extraGroups = [ "docker" ];
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      dates = "weekly";
      enable = true;
      flags = [ "--all" ];
    };
    
    # Add the configuration for frappe/crm
    services = {
      frappe-crm = {
        image = "frappe/crm:latest";  # Use the latest image
        restart = "always";            # Restart policy
        ports = [ "8000:8000" ];      # Map port 8000
        environment = {
          # Add any necessary environment variables here
          # For example:
          # MYSQL_ROOT_PASSWORD = "yourpassword";
        };
      };
    };
  };
}
