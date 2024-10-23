
### GIGA Infrastructure as Code using Nix, Terraform, and AWS

This project deploys an AWS EC2 instance running NixOS using **Terraform**.

---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Setting Up the Environment](#setting-up-the-environment)
  - [Provisioning with Terraform](#provisioning-with-terraform)
  - [NixOS Deploys](#nixos-deploys)
- [NixOS Configuration](#nixos-configuration)

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

This will provide you with an isolated shell where Terraform and AWS CLI are available. Also make sure to create an `inputs.tfvars` file that looks like this:

```
# inputs.tfvars
region = "us-east-1"
flake  = ".#bootstrap"
```

### Provisioning with Terraform

```bash
terraform init
just plan
just apply
```

After the terraform deploy is done, you won't need to use it again. This is only required to bootstrap the infra. Just make sure to ru:
```bash
just rekey
nix fmt
```

### NixOS Deploys

This uses the hostname that was created by terraform it can be found by typing `cat output.json` in the project's root.

```bash
deploy
# or
just deploy
```

---

## NixOS Configuration

Once your EC2 instance is up, the `flake.nix`, `configuration.nix` and `modules` files will define the packages and services you want to install.

---
