#!/bin/bash

# Bitwarden
sudo pacman -S --needed bitwarden bitwarden-cli

# Remove 1Password
sudo pacman -Rns 1password-cli 1password-beta
