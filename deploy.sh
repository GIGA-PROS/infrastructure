#!/usr/bin/env bash

nix run nixpkgs#nixos-rebuild switch \
    -- --flake .#kanagawa \
    --target-host deploy@ec2-44-242-223-134.us-west-2.compute.amazonaws.com \
    --fast \
    --use-remote-sudo
