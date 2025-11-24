#!/bin/bash

# Bitwarden
sudo pacman -S --needed --noconfirm bitwarden bitwarden-cli

# Remove 1Password
pacman -Q 1password-cli && sudo pacman -Rns 1password-cli || echo "1password-cli is not installed"
pacman -Q 1password-beta && sudo pacman -Rns 1password-beta || echo "1password-beta is not installed"
