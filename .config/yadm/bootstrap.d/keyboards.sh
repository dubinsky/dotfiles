#!/bin/bash

# ZSA keyboards support
sudo pacman -S --needed libusb webkit2gtk-4.1 gtk3

# install `keymapp` utility
# follow instructions at https://github.com/zsa/wally/wiki/Linux-install
mkdir -p ~/.local/share/Keymapp
curl -fsSL https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz | tar xzf - -C ~/.local/share/Keymapp || { echo "Download or extraction failed"; exit 1; }
