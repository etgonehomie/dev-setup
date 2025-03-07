#!/bin/bash

# Extract Safe MacOS Config Domains
# This process is a helper function to get the info needed
# to automate setting up environment in macOS
# execute it by using the command `bash [full-pathname]`

# Set variables
GIT_REPO="https://github.com/etgonehomie/dev-setup.git"
PLAYBOOK_FILENAME="mac-backup/mac-export.yml"

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
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
    run_remote_playbook
    log "All steps completed successfully!"
    log "Place this dir in a directory that the setup.yml can read"
    log "Default location is https://github.com/etgonehomie/dev-setup/tree/main/ansible"
}

# Run the main function
main