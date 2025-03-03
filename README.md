# TO-DO
- [ ] make this repo public but ensure no sensitive info is in there
- [ ] ensure all dot files are in the same folder for eaiser maintenance
- [ ] automatic a bash script to make something that whenever .zshrc file is updated, it automatically replaces the cli.md file here
- [ ] ensure auto update of the config files
- [X] Learn how to use `defaults read` on mac to export my mac config files and be able to save it and port it on another mac
- [X] add raycast config files to the ansible playbook
- [X] updated `ls` with `exa`. See this [tutorial](https://www.youtube.com/watch?v=M4UAePWHtbs). Add it to ansible to install and then upd aliases
  - `exa` is no longer active so `eza` was forked see this [repo](https://github.com/eza-community/eza). Add this to ansible and then upd aliases
- git config --global core.excludesfile ~/.gitignore_global
- [ ] Look at various people's dotfiles to see which to copy 
  - Example using chezmoi -> https://github.com/sudopluto/dotfiles/tree/main?tab=readme-ov-file
- [X] add a global .gitignore file and save it in .config folder
- [X] don't use chmod for .dot files, just manually edit and upload to github makes it easier
- [X] review the bash editor as it keeps giving me an error.
- [X] add in raycast as a homebrew
- [X] DON'T USE CHEZMOI. It is overkill for me. just make sure all .dot files are in the same place for easier maintenance. ~~Install Nix package manager for my RPI5~~ 
- [X] ~~Use this [Chezmoi YouTube](https://youtu.be/-RkANM9FfTM?si=CoKFs_fzKWlJnxiY) to make dotfile management easy~~
	- ~~this is the [github repo](https://github.com/logandonley/dotfiles) that does ansible and chezmoi to automate dev setup~~
- [X] ~~This is another [Chezmoi Tutorial](https://medium.com/@alfor93/cross-platform-dotfiles-with-chezmoi-nix-brew-and-devpod-0fd478e40ce)~~
- [X] ~~Setup [Nix Home Manager](https://www.youtube.com/watch?v=xXlCcdPz6Vc) for auto setup dev station with dotfiles and application and app settings. It doesn't work on my work macbook because of certain certs. Use Chezmoi instead~~

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
