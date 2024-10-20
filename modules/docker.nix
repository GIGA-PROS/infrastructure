{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ docker-compose ];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      dates = "weekly";
      enable = true;
      flags = [ "--all" ];
    };
  };

  # OCI Containers - Run Frappe CRM as a systemd service
  virtualisation.oci-containers = {
    backend = "docker";  # Use Docker backend for OCI
    containers = {
      frappe-crm = {
        image = "frappe/crm:latest";  # Pull the latest image from the repo
        restartPolicy = "always";     # Ensure container restarts on failure
        ports = [ "8000:8000" ];      # Map port 8000 to host
        environment = {
          MYSQL_ROOT_PASSWORD = "yourpassword";  # Set MySQL root password
          # Add more necessary environment variables if needed
        };
        volumes = [ 
          "/home/user/frappe/crm/docker/docker-compose.yml:/app/docker-compose.yml",
          "/home/user/frappe/crm/docker/init.sh:/app/init.sh"
        ];
      };
    };
  };

  # Clone the Frappe CRM repository
  system.activationScripts.frappeCRM = ''
    if [ ! -d "/home/user/frappe/crm" ]; then
      echo "Cloning Frappe CRM repository..."
      git clone https://github.com/frappe/crm.git /home/user/frappe/crm
    else
      echo "Frappe CRM repository already cloned."
    fi
  '';
}
