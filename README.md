# TO-DO
- [ ] ensure all dot files are in the same folder for eaiser maintenance
- [ ] automatic a bash script to make something that whenever .zshrc file is updated, it automatically replaces the cli.md 

# Limitations
- currently only for macOS

# Prerequistes:
- Need curl to be installed on your OS

# Process

## Optional: Mac Backup
- This is an optional pre-req step for if you want to backup your safe mac configuration settings.
- If you don't have an existing mac, you can use my .plist (located at `ansible/macos_config_backup`) that the main script uses by default
- The script is located in the `mac-backup` and you can run by cloning the repo and then running `bash mac-backup.sh`

## Main Development Station Automation
1. Run the main script `main.sh`. You can do this by either...
  1. **Via Local**: Clone the repo and run script using:
```
bash ~/main.sh
```
	
  2. **Via Remote**: Curl command:
```
curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/refs/heads/main/main.sh | bash
```
