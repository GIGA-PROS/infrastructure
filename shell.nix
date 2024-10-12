{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # List of packages to include in the shell environment
  buildInputs = [
    pkgs.terraform
    pkgs.awscli
    pkgs.git
  ];

  # Optional: Set environment variables (e.g., AWS credentials)
  # Replace with your actual AWS credentials or use a profile
  AWS_ACCESS_KEY_ID="your-access-key-id"
  AWS_SECRET_ACCESS_KEY="your-secret-access-key"
}
