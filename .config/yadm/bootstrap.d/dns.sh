#!/bin/bash

# `drill` DNS tool
sudo pacman -S --needed --noconfirm ldns

# Enable DHCP search domain (using configuration drop-in)
DROP_INS="/etc/systemd/networkd.conf.d/"
sudo mkdir -p $DROP_INS
sudo cp "$HOME/.config/yadm/$DROP_INS/80-UseDomains.conf" $DROP_INS

# /etc/hosts
HOSTS="/etc/hosts"
sudo cp "$HOME/.config/yadm/$HOSTS" $HOSTS
