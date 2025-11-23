#!/bin/bash

# follow instructions at https://github.com/zsa/wally/wiki/Linux-install

# ZSA keyboards support
sudo pacman -S --needed libusb webkit2gtk-4.1 gtk3

# install `keymapp` utility
KEYMAPP="$HOME/.local/share/keymapp/bin/"
mkdir -p $KEYMAPP
curl -fsSL https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz | \
  tar xzf - -C $KEYMAPP || \
  { echo "Download or extraction failed"; exit 1; }

# install udev rules
RULES="/etc/udev/rules.d/50-zsa.rules"
if [ ! -f $RULES ]; then
  echo "Installing ZSA udev rules"
  sudo cp ./50-zsa.rules $RULES
  sudo groupadd plugdev
  sudo usermod -aG plugdev $USER
  sudo udevadm control --reload
  sudo udevadm trigger
  echo "Log out and back in for the group to apply :)"
fi
