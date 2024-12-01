# TO-DO
- [ ] automatic a bash script to make something that whenever .zshrc file is updated, it automatically replaces the cli.md file here
- [ ] add a global .gitignore file and save it in .config folder
	- git config --global core.excludesfile ~/.gitignore_global 
		- this code wil make it ignore globally
	- git config --global core.excludesfile
		- this checks if it is loaded correctly

# Limitations
- currently only for ARM MacOS

# Prerequistes:
- Need curl to be installed on your OS

# Process
1. Run the `mac_setup.sh`
	- can do this via curl command or download the script and modify/run directly
```
curl -fsSL https://raw.githubusercontent.com/etgonehomie/dev-setup/refs/heads/main/mac_setup.sh | bash
```
OR locally
```
./mac_setup.sh
```
