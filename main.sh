#!/bin/bash

# Developer Setup Automation
# This process is to automate setting up environment in macOS or linux
# execute it by using the command `bash [full-pathname]`
# Set variables
GIT_REPO="https://github.com/etgonehomie/dev-setup.git"
PLAYBOOK_FILENAME="main.yml"    # Replace with your playbook URL

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Helper to get Homebrew install dir
get_brew_prefix() {
    local os=$(uname -s)
    local arch=$(uname -m)

    if [ "$os" = "Darwin" ]; then  # macOS
        if [ "$arch" = "arm64" ]; then
            echo "/opt/homebrew"   # Apple Silicon
        else
            echo "/usr/local"      # Intel macOS
        fi
    else
        echo "/home/linuxbrew/.linuxbrew"  # Linux, WSL, or anything else
    fi
}

# Step 1: Install Homebrew
install_homebrew() {
    log "Starting Homebrew installation..."
    
    # Check if Homebrew is already installed
    if command -v brew &> /dev/null; then
        log "Homebrew is already installed. Skipping installation."
        return 0
    fi

    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    log "Homebrew installation completed successfully."
}

# Step 2: Update homebrew PATH vars
update_homebrew_paths() {
    BREW_PREFIX=$(get_brew_prefix)
    BREW_PATH="$BREW_PREFIX/bin/brew"
    ZSHRC="$HOME/.zshrc"

    # Create .zprofile if it doesn’t exist
    if [ ! -f "$ZSHRC" ]; then
        log "Creating $ZSHRC since it doesn’t exist..."
        touch "$ZSHRC" || {
            log "Error: Failed to create $ZSHRC. Check permissions or directory."
            exit 1
        }
        log "$ZSHRC created successfully."
    fi

    # Append the eval command to .zprofile if it’s not already there
    log "Appending Homebrew shellenv to $ZSHRC..."
    if ! grep -q "eval \"\$($BREW_PATH shellenv)\"" "$ZSHRC"; then
        echo "eval \"\$($BREW_PATH shellenv)\"" >> "$ZSHRC" || {
            log "Error: Failed to write to $ZSHRC. Check permissions."
            exit 1
        }
        log "Successfully appended to $ZSHRC."
    else
        log "Homebrew shellenv already present in $ZSHRC, skipping append."
    fi

    # Evaluate the Homebrew shell environment in the current session
    log "Evaluating Homebrew shellenv in current session..."
    if [ -x "$BREW_PATH" ]; then
        eval "$($BREW_PATH shellenv)" || {
            log "Error: Failed to evaluate $BREW_PATH shellenv."
            exit 1
        }
        log "Homebrew shellenv evaluated successfully."
    else
        log "Error: $BREW_PATH not found or not executable."
        exit 1
    fi

    # Refresh the current shell by sourcing .zshrc
    log "Refreshing terminal to apply changes..."
    source "$ZSHRC"
    log "Terminal refreshed. Homebrew prefix: $(brew --prefix)"
}

# Step 3: Update Homebrew
update_homebrew() {
    log "Updating Homebrew..."
    brew update
    log "Homebrew update completed successfully."
}

# Step 4: Upgrade Homebrew
upgrade_homebrew() {
    log "Upgrading Homebrew packages..."
    brew upgrade
    log "Homebrew upgrade completed successfully."
}

# Step 5: Install Ansible
install_ansible() {
    if ! brew list ansible &> /dev/null; then
        log "Ansible not found. Installing..."
        brew install ansible
        log "Ansible installation completed successfully."
    else
        log "Ansible is already installed."
    fi
}

# Step 1-5 Encapsulated all Ansible Pre-requisites
get_ansible_prereqs() {
    install_homebrew
    update_homebrew_paths
    update_homebrew
    upgrade_homebrew
    install_ansible
}

run_remote_playbook() {
    # Run ansible-pull from GitHub
    log "Executing Ansible playbook from $GIT_REPO..."
    ansible-pull -U "$GIT_REPO" "$PLAYBOOK_FILENAME"

    if [ $? -eq 0 ]; then
        log "Ansible playbook completed successfully."
    else
        log "Error: Ansible playbook failed."
        exit 1
    fi
}

# Main script execution
main() {
    log "Setting up new dev workstation..."

    # Execute steps in synchronous order
    # any functions called within a function execute synchronously
    get_ansible_prereqs     # Comment out for testing for now
    run_remote_playbook
    log "All steps completed successfully!"
}

# Run the main function
main
