# TO-DO
- [ ] automatic a bash script to make something that whenever .zshrc file is updated, it automatically replaces the cli.md file here
- [X] add a global .gitignore file and save it in .config folder
	- git config --global core.excludesfile ~/.gitignore_global 
		- this code wil make it ignore globally
	- git config --global core.excludesfile
		- this checks if it is loaded correctly
- [ ] Maybe don't need this if i use Nix Home Manager. Use this [Chezmoi YouTube](https://youtu.be/-RkANM9FfTM?si=CoKFs_fzKWlJnxiY) to make dotfile management easy
- [ ] This is another [Chezmoi Tutorial](https://medium.com/@alfor93/cross-platform-dotfiles-with-chezmoi-nix-brew-and-devpod-0fdb478e40ce)
- [X] Setup [Nix Home Manager](https://www.youtube.com/watch?v=xXlCcdPz6Vc) for auto setup dev station with dotfiles and application and app settings. It doesn't work on my work macbook because of certain certs. Use Chezmoi instead
- [ ] Look at various people's dotfiles to see which to copy 
  - Example using chezmoi -> https://github.com/sudopluto/dotfiles/tree/main?tab=readme-ov-file

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
