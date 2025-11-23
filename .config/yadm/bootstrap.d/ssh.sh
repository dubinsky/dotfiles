#!/bin/bash

# install Yubikey utilities
sudo pacman -S --needed yubikey-personalization-gui yubikey-manager libfido2

# enable SSH agent
systemctl enable --now --user ssh-agent.service

# enable SSH server
sudo systemctl enable --now sshd.service
