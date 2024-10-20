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
    backend = "docker";  
    containers = {
      frappe-crm = {
        image = "frappe/crm:latest";  
        restartPolicy = "always";
        ports = [ "8000:8000" ];      
        environment = {
          MYSQL_ROOT_PASSWORD = "yourpassword"; 
        };
        volumes = [ 
          "/home/user/frappe/crm/docker/docker-compose.yml:/app/docker-compose.yml"
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
