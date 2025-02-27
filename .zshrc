
# Set Terminal Home Starting
cd ~

## This allows me to use homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

####################################
# Variables
####################################
export EDITOR=nvim
BREW_PREFIX=$(brew --prefix)
CONFIG_FILE=${CONFIG_FILE:-~/.zshrc}
PERSONAL_DIR="~/git-projects/personal"
WORK_DIR="~/git-projects/work"     

####################################
# Quick links to project dirs
####################################
alias home='cd ~'
alias setup="cd $PERSONAL_DIR/dev-setup"
alias dev=setup
alias tesla="cd $PERSONAL_DIR/tesla-tracker"
alias tes=tesla

# Use specific SSH keys based on directory
if [[ $(pwd) == $PERSONAL_DIR/* ]]; then
  export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_personal"
elif [[ $(pwd) == $WORK_DIR/* ]]; then
  export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_work"
fi

# Change this to be .config/oh-my-posh/[theme.toml/yaml/json] if desired
# Info for how to use this theming: https://ohmyposh.dev/docs
OH_MY_POSH_THEME_PATH="$BREW_PREFIX/share/oh-my-posh/themes/zen-mod.toml"

########################################################################

# Set oh-my-posh theme
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $OH_MY_POSH_THEME_PATH)"
fi

# Set quick file path movement for projects
alias auto='cd $PROJ_DIR/windsurf/auto-image'
alias react='cd $PROJ_DIR/react-learning/auto-image'
alias autoimage='react'
alias auto-image='react'
alias cc='cd $PROJ_DIR/cc-churning-app'
alias churn=cc
alias tools='cd $PROJ_DIR/tools'
alias tool=tools

# Enable CLI tools
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
source "$BREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

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

# Chezmoi dotfile manager
alias dot='cd $HOME/.local/share/chezmoi'
alias cvi='chezmoi edit'

# CLI - Random Aliases
alias ..='cd ..'
alias test='echo hello-world'
alias update='sudo apt-get update && sudo apt-get upgrade -y && sudo snap refresh'
alias upd='update'
alias yml='$EDITOR docker-compose.yml'
alias yaml='yml'
alias myips='ip addr'
alias myip='myips'

# CLI - Modify Files Aliases
alias ver='version'
alias mk='touch'
alias create='touch'
alias rename='mv'

# Go into Config File to Edit Aliases
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias vimdiff='nvim -d'
alias vdif='vimdiff'
alias vdiff='vimdiff'

# List Aliases
alias ls='ls --color=auto'
alias lsl='ls -l'
alias lsh='ls -h' 
alias lsa='ls -a'
alias list='ls -l -h -a'
alias l='list'

# Grep (find) Aliases
alias grep='grep --color=auto'

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
alias ga='git add'
alias gaa='git add .'
alias gb='git branch'
alias gch='git checkout -b'
alias gcm='git commit -m'
alias gcam='git commit -am' # add all and commit with a message
alias gs='git status'
alias gsw='git switch'
alias push='git push origin'
alias gpush='push'
alias pull='git pull origin'
alias gpull='pull'

# SSH Aliases
# Add private ssh key to agent to enable ssh access to pi
# ssh-add ~/.ssh/homeserver

# Ansible
alias arun='ansible-playbook ~/homeserver/main.yml'
