#!/bin/bash

# `drill` DNS tool
sudo pacman -S --needed ldns

# Enable DHCP search domain (using configuration drop-in)
DROP_INS="/etc/systemd/networkd.conf.d/"
sudo mkdir -p $DROP_INS
sudo cp "./$DROP_INS/80-UseDomains.conf" $DROP_INS
