#!/bin/bash

# get package updates as soon as they are available (live on the edge)
omarchy-refresh-pacman-mirrorlist edge

# firmware upgrader
sudo pacman -S --needed fwupd
