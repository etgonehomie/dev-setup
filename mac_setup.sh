# Developer Setup Automation
# This process is to automate setting up environment in macOS or linux
# execute it by using the command `sh [full-pathname]`

!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set variables
PLAYBOOK_URL="hhttps://raw.githubusercontent.com/etgonehomie/dev-setup/refs/heads/main/" # Replace with your playbook URL
PLAYBOOK_FILE="setup.yml"    

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
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

# Step 2: Update Homebrew
update_homebrew() {
    log "Updating Homebrew..."
    brew update
    log "Homebrew update completed successfully."
}

# Step 3: Upgrade Homebrew
upgrade_homebrew() {
    log "Upgrading Homebrew packages..."
    brew upgrade
    log "Homebrew upgrade completed successfully."
}

# Step 4: Install Ansible
install_ansible() {
    if ! brew list ansible &> /dev/null; then
        log "Ansible not found. Installing..."
        brew install ansible
        log "Ansible installation completed successfully."
    else
        log "Ansible is already installed."
    fi
}

# Step 5: Download Ansible Playbook
get_ansible_playbook() {
    echo "Downloading Ansible playbook from $PLAYBOOK_URL..."
    curl -fsSL -o "$PLAYBOOK_FILE" "$PLAYBOOK_URL"
    if [[ $? -ne 0 ]]; then
        echo "Failed to download the playbook. Exiting."
    exit 1
    fi
}

# Run the playbook
run_ansible_playbook() {
    echo "Running Ansible playbook..."
    ansible-playbook "$PLAYBOOK_FILE"

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
    log "Starting Homebrew and Ansible installation process..."

    # Execute steps in synchronous order
    # any functions called within a function execute synchronously
    install_homebrew
    update_homebrew
    upgrade_homebrew
    install_ansible
    get_ansible_playbook
    run_ansible_playbook
    log "All steps completed successfully!"
}

# Run the main function
main