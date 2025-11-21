#!/bin/bash

# Yubikey
sudo pacman -S --needed yubikey-personalization-gui yubikey-manager libfido2

# enable SSH agent
systemctl enable --now --user ssh-agent.service
