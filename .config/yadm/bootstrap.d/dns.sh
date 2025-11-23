#!/bin/bash

# `drill` DNS tool
sudo pacman -S --needed ldns

# Enable DHCP search domain (using configuration drop-in)
sudo mkdir -p /etc/systemd/networkd.conf.d/
sudo cp ./etc/systemd/networkd.conf.d/80-UseDomains.conf /etc/systemd/networkd.conf.d/
