provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "nixos_arm64" {
  owners      = ["427812963091"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nixos/24.05*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_instance" "nixos_arm64" {
  ami           = data.aws_ami.nixos_arm64.id
  instance_type = "t4g.small"
  key_name      = "your-key-name"

  tags = {
    Name = "NixOS-EC2"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.nixos_arm64.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo nix-channel --add https://nixos.org/channels/nixos-24.05 nixos",
      "sudo nix-channel --update",
      "sudo nixos-rebuild switch"
    ]
  }
}
