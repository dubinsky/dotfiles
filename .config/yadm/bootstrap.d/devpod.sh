#!/bin/bash

# Yay! Arch community already packages the community fork of DevPod -
# see https://aur.archlinux.org/packages/devpod-community-bin:
yay -S --needed --noconfirm devpod-community-bin

# DevPod is written in Go, so for developing it we need:
sudo pacman -S --needed --noconfirm go go-tools golangci-lint go-task goreleaser

echo "Install pre-commit zipapp from https://pre-commit.com/#install"
