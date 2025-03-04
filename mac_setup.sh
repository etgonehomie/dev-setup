# Developer Setup Automation
# This process is to automate setting up environment in macOS or linux
# execute it by using the command `sh [full-pathname]`

#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set variables
PLAYBOOK_URL="https://raw.githubusercontent.com/etgonehomie/dev-setup/refs/heads/main/ansible/setup.yml" # Replace with your playbook URL
PLAYBOOK_LOCAL_FILEPATH="$HOME/setup.yml"    

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
    BREW_SHELLENV="$HOME/bin/brew shellenv"
    ZSHRC="$HOME/.zshrc"


    # Append the eval command to .zprofile if it’s not already there
    echo "Appending Homebrew shellenv to $ZPROFILE..."
    if ! grep -q "eval \"\$($BREW_SHELLENV)\"" "$ZPROFILE"; then
        echo "eval \"\$($BREW_SHELLENV)\"" >> "$ZPROFILE" || {
            echo "Error: Failed to write to $ZPROFILE. Check permissions."
            exit 1
        }
        echo "Successfully appended to $ZPROFILE."
    else
        echo "Homebrew shellenv already present in $ZPROFILE, skipping append."
    fi

    # Evaluate the Homebrew shell environment in the current session
    echo "Evaluating Homebrew shellenv in current session..."
    if [ -x "$BREW_SHELLENV" ]; then
        eval "$($BREW_SHELLENV)" || {
            echo "Error: Failed to evaluate $BREW_SHELLENV."
            exit 1
        }
        echo "Homebrew shellenv evaluated successfully."
    else
        echo "Error: $BREW_SHELLENV not found or not executable."
        exit 1
    fi
}

# Step 2: Update Homebrew
update_homebrew() {
    log "Updating Homebrew..."
    BREW_PREFIX=$(get_brew_prefix)
    "$BREW_PREFIX/bin/brew" update
    log "Homebrew update completed successfully."
}

# Step 3: Upgrade Homebrew
upgrade_homebrew() {
    log "Upgrading Homebrew packages..."
    BREW_PREFIX=$(get_brew_prefix)
    "$BREW_PREFIX/bin/brew" upgrade
    log "Homebrew upgrade completed successfully."
}

# Step 4: Install Ansible
install_ansible() {
    if ! brew list ansible &> /dev/null; then
        log "Ansible not found. Installing..."
        BREW_PREFIX=$(get_brew_prefix)
        "$BREW_PREFIX/bin/brew" install ansible
        log "Ansible installation completed successfully."
    else
        log "Ansible is already installed."
    fi
}

# Step 1-4 Encapsulated all Ansible Pre-requisites
get_ansible_prereqs() {
    install_homebrew
    update_homebrew
    upgrade_homebrew
    install_ansible
}
# Step 5: Download Ansible Playbook
get_ansible_playbook() {
    echo "Downloading Ansible playbook from $PLAYBOOK_URL..."
    echo "remote playbook: $PLAYBOOK_URL"
    echo "local file: $PLAYBOOK_LOCAL_FILEPATH"
    curl -fsSL -o "$PLAYBOOK_LOCAL_FILEPATH" "$PLAYBOOK_URL"
    if [[ $? -ne 0 ]]; then
        echo "Failed to download the playbook. Exiting."
    exit 1
    fi
}

# Run the playbook
run_ansible_playbook() {
    echo "Running Ansible playbook..."
    BREW_PREFIX=$(get_brew_prefix)
    "$BREW_PREFIX/bin/ansible-playbook" "$PLAYBOOK_LOCAL_FILEPATH"

    # Check if the playbook ran successfully
    if [[ $? -eq 0 ]]; then
      echo "Playbook executed successfully!"
    else
      echo "An error occurred while running the playbook."
      exit 1
    fi    
}

# Main script execution
main() {
    log "Setting up new dev workstation..."

    # Execute steps in synchronous order
    # any functions called within a function execute synchronously
    get_ansible_prereqs     # Comment out for testing for now
    get_ansible_playbook
    run_ansible_playbook
    log "All steps completed successfully!"
}

# Run the main function
main
