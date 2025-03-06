#!/bin/bash

# Extract Safe MacOS Config Domains
# This process is a helpful function to get the info needed
# to automate setting up environment in macOS
# execute it by using the command `bash [full-pathname]`

# Set variables
GIT_REPO="https://github.com/etgonehomie/dev-setup.git"
PLAYBOOK_FILENAME="mac-backup/mac-export.yml"
PASSWORD_FILE="password_mac_export.env"
VAULT_PW_FILEPATH="$HOME/git-projects/personal/dev-setup/$PASSWORD_FILE"  

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

run_remote_playbook() {
    # Run ansible-pull from GitHub
    log "Executing Ansible playbook from $GIT_REPO..."

    # Encrypt files using the given password file
    # Don't change as this same one is used to decrypt in the mac-setup.yml
    # which is stored in vault.yml
    ansible-pull -U "$GIT_REPO" "$PLAYBOOK_FILENAME" --vault-password-file "$VAULT_PW_FILEPATH"

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