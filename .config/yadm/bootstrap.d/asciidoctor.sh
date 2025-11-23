#!/bin/bash

sudo pacman -S --needed rubygems asciidoctor asciidoctor-pdf

gem install --user-install asciidoctor-multipage
