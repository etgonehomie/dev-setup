# TO-DO
- [ ] automatic a bash script to make something that whenever .zshrc file is updated, it automatically replaces the cli.md file here
- [ ] update my dev-setup using nix
	- https://www.youtube.com/watch?v=Z8BL8mdzWHI
- [X] add a global .gitignore file and save it in .config folder
	- git config --global core.excludesfile ~/.gitignore_global 
		- this code wil make it ignore globally
	- git config --global core.excludesfile
		- this checks if it is loaded correctly
- [ ] Use this to make dotfile management easy:
  -  https://www.youtube.com/watch?v=y6XCebnB9gs&t=28s

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
