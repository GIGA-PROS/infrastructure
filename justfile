set export := true

modules := justfile_directory() + "/module"
release := `git tag -l --sort=-creatordate | head -n 1`
replace := if os() == "linux" { "sed -i" } else { "sed -i '' -e" }

# For lazy people
alias r := run

# Lists all availiable targets
default:
    just --list

# Builds the remote AWS EC2 VM
build:
    nix build .#nixosConfigurations.kanagawa.config.system.build.toplevel

# Deploys the VM to EC2
deploy:
    ./deploy.sh

# Runs a Qemu VM
run:
    nix run
