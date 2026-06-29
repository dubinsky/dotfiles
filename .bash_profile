#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# For PATH changes to take effect, re-log in.

# JetBrains Toolbox
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"

# Keymapp
export PATH="$PATH:$HOME/.local/share/keymapp/bin"

# Agda
export PATH="$PATH:$HOME/.local/share/agda"

# Devcontainer CLI
export PATH="$PATH:$HOME/.devcontainers/bin"
