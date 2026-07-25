#!/bin/zsh
[[ -n "$ZSH_VERSION" ]] || return
[[ -o interactive ]] || return

####################################
# Homebrew bootstrap
####################################
if [[ -x /opt/homebrew/bin/brew ]]; then
  BREW_PREFIX=/opt/homebrew
elif [[ -x /usr/local/bin/brew ]]; then
  BREW_PREFIX=/usr/local
else
  echo "Homebrew not found in common locations"
  return 1
fi

if [[ "${HOMEBREW_PREFIX:-}" != "$BREW_PREFIX" ]]; then
  eval "$($BREW_PREFIX/bin/brew shellenv)"
fi

####################################
# Shell plugins (order matters)
####################################
source_if_exists() {
  # Usage: source_if_exists <file-path>
  # Sources the file only when it exists.
  [[ -f "$1" ]] && source "$1"
}

source_if_exists "$BREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source_if_exists "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_if_exists "$BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

####################################
# Environment and config
####################################
CONFIG_FILE=${CONFIG_FILE:-~/.zshrc}
PERSONAL_DIR=~/git-projects/personal
WORK_DIR=~/git-projects/work
OH_MY_POSH_THEME_PATH="$BREW_PREFIX/share/oh-my-posh/themes/zen.toml"

export EDITOR=nvim
export GIT_CONFIG_GLOBAL=~/.config/git/.gitconfig
export ODBCINI="$BREW_PREFIX/etc/odbc.ini"
export ODBCSYSINI="$BREW_PREFIX/etc"
export ODBCINSTINI="odbcinst.ini"

if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
  eval "$(oh-my-posh init zsh --config "$OH_MY_POSH_THEME_PATH")"
fi

####################################
# Core utility functions
####################################
reload_shell() {
  # Usage: reload_shell
  # Reloads this shell config file and prints a success message.
  source "$CONFIG_FILE"
  echo "\e[32mConfig reloaded ✓\e[0m"
}

mkcd() {
  # Usage: mkcd <directory>
  # Creates the directory (including parents) and cd's into it.
  mkdir -p "$1" && cd "$1"
}

cproj() {
  # Usage: cproj
  # Changes directory to the personal projects root.
  cd ~/git-projects/personal
}

cwork() {
  # Usage: cwork
  # Changes directory to the work projects root.
  cd ~/git-projects/work
}

cdf() {
  # Usage: cdf
  # Changes directory to the current Finder insertion location (macOS).
  local target
  target="$(osascript -e 'tell application "Finder" to POSIX path of (insertion location as alias)' 2>/dev/null)"
  [[ -n "$target" ]] && cd "$target"
}

venv_create() {
  # Usage: venv_create
  # Creates a Python virtual environment in .venv.
  python3 -m venv .venv
}

venv_on() {
  # Usage: venv_on
  # Activates the local .venv virtual environment.
  source .venv/bin/activate
}

venv_off() {
  # Usage: venv_off
  # Deactivates the current Python virtual environment.
  deactivate
}

brew_maint() {
  # Usage: brew_maint
  # Runs Homebrew maintenance (update, upgrade, cleanup, doctor) and returns nonzero if any step fails.
  local rc=0
  brew update || rc=1
  brew upgrade || rc=1
  brew cleanup -s || rc=1
  brew doctor || rc=1
  return $rc
}

gsync() {
  # Usage: gsync
  # Fetches origin and rebases the current branch onto origin/<current-branch>.
  local branch
  branch="$(git branch --show-current)"
  git fetch origin && git rebase "origin/$branch"
}

gundo() {
  # Usage: gundo
  # Prompts, then undoes the last commit with a soft reset (keeps changes staged).
  local last_commit
  last_commit="$(git log -1 --pretty='format:%h %s' 2>/dev/null)" || return 1
  echo "About to undo commit: $last_commit"
  read -q "REPLY?Proceed with git reset --soft HEAD~1? [y/N] "
  echo
  [[ "$REPLY" =~ ^[Yy]$ ]] || return 1
  git reset --soft HEAD~1
}

gprune() {
  # Usage: gprune
  # Prompts to delete merged local branches, excluding protected/common branch names.
  local current candidates
  current="$(git branch --show-current)"
  candidates="$(git branch --merged | grep -vE "^\*|main|master|develop|$current$")"
  [[ -z "$candidates" ]] && {
    echo "No merged local branches to prune."
    return 0
  }
  echo "Merged branches to delete:"
  echo "$candidates"
  read -q "REPLY?Delete these branches? [y/N] "
  echo
  [[ "$REPLY" =~ ^[Yy]$ ]] || return 1
  git fetch --prune
  echo "$candidates" | xargs -n 1 git branch -d
}

gpr() {
  # Usage: gpr <branch-name> <commit-message>
  # Creates a branch, commits with the message, pushes upstream, and opens a PR to main.
  if [[ $# -lt 2 ]]; then
    echo "Usage: gpr <branch-name> <commit-message>"
    return 1
  fi

  local branch="$1"
  shift
  local commit_msg="$*"

  git switch -c "$branch" || return 1
  git commit -m "$commit_msg" || return 1
  git push -u origin "$branch" || return 1
  gh pr create --base main --head "$branch" --title "$commit_msg" --body "$commit_msg"
}

gcleanup() {
  # Usage: gcleanup
  # Squash-merges the current PR, deletes its branch, then syncs local main.
  gh pr merge --squash --delete-branch || return 1
  git switch main || return 1
  git pull origin main || return 1
}

groot() {
  # Usage: groot
  # Changes directory to the root of the current Git repository.
  cd "$(git rev-parse --show-toplevel)"
}

####################################
# Aliases - config and navigation
####################################
alias config='$EDITOR $CONFIG_FILE'
alias z='config'


alias reload='reload_shell'
alias refresh=reload
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias p='cproj'
alias w='cwork'

####################################
# Aliases - editor and files
####################################
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias vimdiff='nvim -d'
alias yml='$EDITOR docker-compose.yml'
alias mk='touch'
alias rename='mv'

####################################
# Aliases - listing and search
####################################
alias ls="$BREW_PREFIX/bin/eza --long --all --git --group-directories-first"
alias l='ls'
alias grep='grep --color=auto'

####################################
# Aliases - Python
####################################
alias python='python3'
alias py='python3'

####################################
# Aliases - Docker/Colima
####################################
alias dstart='colima start'
alias dstop='colima stop'
alias dstatus='colima status'

####################################
# Aliases - Git
####################################
alias gst='git status'
alias ga='git add'
alias gaa='git add . && git status'
alias gc='git commit -m'
alias gca='git commit -am'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gsw='git switch'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gds='git diff --staged'
alias grh='git reset --hard'
alias gpf='git push --force-with-lease'
alias gbl='git blame'
alias grv='git remote -v'
alias groot='groot'
alias gpull='git pull --rebase'
alias gpush='git push'
alias gsta='git stash push'
alias gstp='git stash pop'
alias gunstage='git restore --staged'
alias glast='git log -1 --stat'

####################################
# Optional SSH identity by folder
####################################
set_git_ssh_identity() {
  # Usage: set_git_ssh_identity
  # Sets GIT_SSH_COMMAND based on whether you're in personal or work project folders.
  if [[ "$PWD" == "$PERSONAL_DIR"/* ]]; then
    export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_personal"
  elif [[ "$PWD" == "$WORK_DIR"/* ]]; then
    export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_work"
  else
    unset GIT_SSH_COMMAND
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd set_git_ssh_identity
set_git_ssh_identity
