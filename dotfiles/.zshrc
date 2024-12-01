## This allows me to use homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# SET STARTING TO HOME
cd ~

# Variables
EDITOR=${EDITOR:-nano}
CONFIG_FILE=${CONFIG_FILE:-~/.zshrc}
BREW_PREFIX=$(brew --prefix)
PROJ_DIR=${PROJ_DIR:-~/git-projects}
# PROJ_DIR='~/git-projects'

# Set quick file path movement for projects
alias auto='cd $PROJ_DIR/windsurf/auto-image'
alias react='cd $PROJ_DIR/react'
alias cc='cd $PROJ_DIR/cc-churning-app'
alias churn=cc
alias dev='cd $PROJ_DIR/dev-setup'
alias setup=dev

# Enable CLI tools
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $BREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# Edit Config File Alias
alias config="$EDITOR $CONFIG_FILE"
alias conf='config'
alias con='config'
alias z='config'

# Refresh config file code
refresh_function() {
    source "$CONFIG_FILE"
    echo -e "\e[32mConfig file has been refreshed! ✓\e[0m"
}
alias refresh='refresh_function'
alias ref='refresh_function'
alias r='refresh_function'
alias reload='refresh_function'
alias re='refresh_function'

# Homebrew Aliases
## brew update <-- updates the brew package insataller
## brew upgrade <-- updates packages that brew installed
alias brew up='brew update && brew upgrade'

## Brewfile is all the packages installed and maintained by homebrew
alias brewfile='$EDITOR ~/Brewfile'
alias bfile=brewfile

# CLI - Random Aliases
alias test='echo hello-world'
alias update='sudo apt-get update && sudo apt-get upgrade -y && sudo snap refresh'
alias upd='update'
alias ..='cd ..'
alias temp='sudo chown et'
alias yml='$EDITOR docker-compose.yml'
alias yaml='yml'
alias myips='ip addr'
alias myip='myips'

# CLI - Modify Files Aliases
alias v='version'
alias mk='touch'
alias create='touch'
alias rename='mv'

# Go into Config File to Edit Aliases
alias vim='nvim'

# List Aliases
alias lsl='ls -l'
alias lsh='ls -h'
alias lsa='ls -a'
alias list='ls -l -h -a'
alias l='list'

# Python Aliases
alias python='python3'
alias py='python'

# VENV Aliases
# source [vpathname]/activate <- activates the venv
# deactivate <- deactivates
# alias v='py -m venv' # this creates a venv where you then have to put a '.' director name after 
  # for example v .my_venv_proj <-- this creates a venv for the project folder .my_venv_proj
alias deact='deactivate'

# Git Aliases
alias g='git'
alias gb='g branch'
alias ga='g add'
alias gcm='g commit -m'
alias gcam='g commit -am' # add all and commit with a message
alias push='g push origin'
alias gpush='push'
alias pull='g pull origin'
alias gpull='pull'

# SSH Aliases
# Add private ssh key to agent to enable ssh access to pi
# ssh-add ~/.ssh/homeserver

# Ansible
alias arun='ansible-playbook ~/homeserver/main.yml'