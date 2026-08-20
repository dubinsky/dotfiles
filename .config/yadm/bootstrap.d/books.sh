#!/bin/bash

# ebooks
sudo pacman -S --needed --noconfirm calibre

# PDFs — official Zotero Linux tarball (AUR `zotero` compiles from git/npm)
yay -S --needed --noconfirm zotero-bin

# syncthing
sudo pacman -S --needed --noconfirm syncthing
