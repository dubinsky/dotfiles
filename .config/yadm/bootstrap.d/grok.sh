#!/bin/bash

# Grok Build CLI. The tool spec is in ~/.config/mise/config.toml
# (official binary, not npm:@xai-official/grok, and not Grok Bot).
# New releases are younger than mise's default minimum age.
export MISE_MINIMUM_RELEASE_AGE=0
mise install grok
