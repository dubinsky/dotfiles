#!/bin/bash

sudo packman -S --needed rubygems asciidoctor asciidoctor-pdf

gem install --user-install asciidoctor-multipage
