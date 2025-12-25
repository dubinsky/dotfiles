#!/bin/bash

# install Yubikey utilities
sudo pacman -S --needed --noconfirm yubikey-personalization-gui yubikey-manager libfido2

# enable SSH agent
systemctl enable --now --user ssh-agent.service

# enable SSH server
sudo systemctl enable --now sshd.service

# update yadm repo origin URL
yadm remote set-url origin "git@github.com:dubinsky/dotfiles.git"

# pre-create control directory
mkdir -p ~/.ssh/control
