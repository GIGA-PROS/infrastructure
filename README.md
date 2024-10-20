
### GIGA Infrastructure as Code using Nix, ToFu, and AWS

This project deploys an AWS EC2 instance running NixOS using **ToFu**.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setting Up the Environment](#setting-up-the-environment)
3. [ToFu Configuration](#tofu-configuration)
4. [NixOS Configuration](#nixos-configuration)
5. [Running the Deployment](#running-the-deployment)
6. [File Structure](#file-structure)

---

## Prerequisites

Before you begin, ensure you have the following installed on your local machine:

- **Nix**: [Installation guide](https://nixos.org/download.html)
- **ToFu**: [ToFu documentation](https://github.com/NixOS/tofu)
- **AWS CLI**: Optional, but useful for managing AWS resources directly.

---

## Setting Up the Environment

This repository contains a `shell.nix` file that provides an environment with all the required dependencies (ToFu, AWS CLI, Git, etc.).

To enter the environment, use the following command:

```bash
nix develop --impure
```
or use [direnv](https://github.com/direnv/direnv).

This will provide you with an isolated shell where Terraform and AWS CLI are available.

### Provisioning with Terraform

```bash
just update-vars
terraform init
just plan
just apply
```

After the terraform deploy is done, you won't need to use it again. This is only required to bootstrap the infra.

### NixOS Deploys

This uses the hostname that was created by terraform it can be found by typing `cat output.json` in the project's root.

```bash
deploy
# or
just deploy
```

---

## NixOS Configuration

Once your EC2 instance is up, the `configuration.nix` file will define the packages and services you want to install, similar to the previous ToFu setup.

### `configuration.nix`

```nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [ "/dev/xvda" ];

  networking.hostName = "nixos-ec2-tofu";
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.ec2-user = {
    isNormalUser = true;
    home = "/home/ec2-user";
    shell = pkgs.bash;
    extraGroups = [ "wheel" "docker" ];
  };

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

  services.docker.enable = true;

  services.caddy = {
    enable = true;
    config = ''
      :80 {
        reverse_proxy localhost:3000
      }
    '';
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    initialScript = ''
      CREATE USER ec2-user WITH PASSWORD 'password';
      CREATE DATABASE mydatabase OWNER ec2-user;
    '';
  };

  services.redis.enable = true;

  services.phpfpm.enable = true;

  systemd.services.docker.enable = true;
}
```

---

## Running the Deployment

### Steps to deploy using **ToFu**:

1. **Enter the Nix shell** (if using `shell.nix`):
   ```bash
   nix-shell
   ```

2. **Deploy the EC2 instance using ToFu**:
   ```bash
   $
   ```

3. **SSH into the instance** (replace `your-instance-ip` with the actual IP address provided by ToFu):
   ```bash
   ssh ec2-user@your-instance-ip
   ```

4. **Confirm services** such as Caddy, Docker, PostgreSQL, Redis, etc., are running.

---

## File Structure

```
.
├── main.tf                  # ToFu configuration for the EC2 instance
├── configuration.nix         # NixOS system configuration
└── shell.nix                 # Nix shell for working with ToFu
```

---
