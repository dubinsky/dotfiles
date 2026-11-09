#!/bin/bash

# follow instructions at https://github.com/zsa/wally/wiki/Linux-install

# ZSA keyboards support
sudo pacman -S --needed --noconfirm libusb webkit2gtk-4.1 gtk3

# install `keymapp` utility
KEYMAPP="$HOME/.local/share/keymapp/bin/"
mkdir -p $KEYMAPP
curl -fsSL https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz | \
  tar xzf - -C $KEYMAPP || \
  { echo "Download or extraction failed"; exit 1; }

# The tarball is only the binary and icon.png. Apps reads a .desktop file.
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/keymapp.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Keymapp
Comment=View and flash a ZSA keyboard layout
Exec=$HOME/.local/share/keymapp/bin/keymapp
Icon=$HOME/.local/share/keymapp/bin/icon.png
Terminal=false
Categories=Utility;
StartupNotify=true
StartupWMClass=Keymapp
EOF

# install udev rules
RULES="/etc/udev/rules.d/"
if [ ! -f "$RULES/50-zsa.rules" ]; then
  echo "Installing ZSA udev rules"
  sudo mkdir -p $RULES
  sudo cp "$HOME/.config/yadm/$RULES/50-zsa.rules" $RULES
  sudo groupadd plugdev
  sudo usermod -aG plugdev $USER
  sudo udevadm control --reload
  sudo udevadm trigger
  echo "Log out and back in for the group to apply :)"
fi
