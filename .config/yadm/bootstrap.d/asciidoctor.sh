#!/bin/bash

sudo pacman -S --needed --noconfirm rubygems asciidoctor asciidoctor-pdf

gem install --user-install asciidoctor-multipage
