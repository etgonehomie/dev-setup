#!/bin/bash

# Extract Safe MacOS Config Domains
# This process is a helpful function to get the info needed
# to automate setting up environment in macOS
# execute it by using the command `bash [full-pathname]`

# Set variables
GIT_REPO="https://github.com/etgonehomie/dev-setup.git"
PLAYBOOK_DIR="mac-backup"
PLAYBOOK_FILENAME="mac-export.yml"
PLAYBOOK_URL="https://raw.githubusercontent.com/etgonehomie/dev-setup/refs/heads/main/$PLAYBOOK_DIR/$PLAYBOOK_FILENAME" # Replace with your playbook URL
VAULT_PW_FILEPATH="$HOME/git-projects/personal/dev-setup/ansible-vault-pw.env"  

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

run_remote_playbook() {
    # Run ansible-pull from GitHub
    log "Executing Ansible playbook from $REPO_URL..."
    ansible-pull -U "$GIT_REPO" -i localhost, "$PLAYBOOK_DIR/$PLAYBOOK_FILENAME" --vault-password-file "$VAULT_PW_FILEPATH"

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
    run_remote_playbook
    log "All steps completed successfully!"
}

# Run the main function
main