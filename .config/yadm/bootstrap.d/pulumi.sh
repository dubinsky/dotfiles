#!/bin/bash

# Pulumi
sudo pacman -S --needed pulumi

# Besom
pulumi plugin install language scala 0.5.0 --server github://api.github.com/VirtusLab/besom
