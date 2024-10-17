set export := true

modules := justfile_directory() + "/module"
release := `git tag -l --sort=-creatordate | head -n 1`
replace := if os() == "linux" { "sed -i" } else { "sed -i '' -e" }

# For lazy people
alias r := run

# Lists all availiable targets
default:
    just --list

# Builds a Qemu VM
build:
    nix run

# Runs a Qemu VM
run:
    nix run
