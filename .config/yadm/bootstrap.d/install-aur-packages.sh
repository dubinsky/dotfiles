#!/bin/bash

grep -v "^#" aur-packages.txt | yay -S --needed -
