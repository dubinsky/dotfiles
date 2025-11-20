#!/bin/bash

grep -v "^#" arch-packages.txt | sudo pacman -S --needed -
