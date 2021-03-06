#!/bin/bash

# ------------------------------------------------------------------------------ 
# README
# This is a script to setup my daily driver environment on a machine. It assumes
# that the current user is `root` and the normally logged in user is `bsuth`.
# ------------------------------------------------------------------------------

# This script's parent directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Status
status=0

# ANSI color codes
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)"

# ------------------------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------------------------

function _report_status_() {
	case $status in
		0) echo -e "\n${GREEN}--> Success! <--${NC}\n" ;;
		1) echo -e "\n${RED}--> Failed <--${NC}\n" ;;
		2|*) echo -e "\n${RED}--> Skipped <--${NC}\n" ;;
	esac	    
}

function _yesno_() {
	while true; do
		printf "$1 (y/n): "
		read yn

		case "$yn" in
			y|Y) return 0 ;;
			n|N) return 1 ;;
			*) echo -e "${RED}Invalid input${NC}\n"
		esac
	done
}

function _prompt_continue_() {
	if ! _yesno_ "Continue?"; then
		status=1; _report_status_
		exit 0
	else
		status=2
	fi
}

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

if [[ $UID != 0 ]]; then
	echo "${RED}This script must be run as root.${NC}"
	exit 1
fi

echo

## Install Packages ## 

function _install_packages_() {
	declare -a packages=(
		# system
		zsh
		dconf-cli
		cinammon
		
		# cli tools
		fd-find
		curl
		npm
		htop
        pass
		
		# apps
        flameshot
        anki
		gnome-terminal
	)

	if ! _yesno_ "Install packages?"; then status=2; return; fi
	apt install "${packages[@]}"

	# ripgrep
	curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
	dpkg -i ripgrep_11.0.2_amd64.deb
	rm ripgrep_11.0.2_amd64.deb

	# vivaldi
	wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | apt-key add -
	add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'
	
	apt update
	apt install vivaldi-stable 
	status=0
}

echo -e "${GREEN}=== Installing packages ===${NC}\n"
_install_packages_
_report_status_


## Update sudoers ## 

function _system_config_() {
    echo
    
    printf "Adding bsuth to sudoers..."
	sudo adduser bsuth sudo >/dev/null 2>&1
	echo "${GREEN}done${NC}"
	
	printf "Configuring git..."
	git config --global user.email "bsuth701@gmail.com"
	echo "${GREEN}done${NC}"
	
	printf "Setting default shell to zsh..."
	chsh -s /bin/zsh bsuth
	echo "${GREEN}done${NC}"
	
	status=0
}

echo -e "${GREEN}=== System Configuration ===${NC}"
_system_config_
_report_status_

## Setup Symlinks ##

function _setup_symlinks_() {
	declare -A symlinks=(
		["Documents/ssh"]=".ssh"
		["Documents/gnupg"]=".gnupg"
		["Documents/password-store"]=".password-store"
		["dots/.Xmodmap"]=".Xmodmap"
		["dots/.zshrc"]=".zshrc"
		["dots/.zprofile"]=".zprofile"
		["dots/awesome"]=".config/awesome"
		["dots/rofi"]=".config/rofi"
	)

	if ! _yesno_ "Setup symlinks?"; then status=2; return; fi
	failedsymlinks=0

	for symlink in ${!symlinks[@]}; do
		printf "Linking ~/${symlink} -> ~/${symlinks[$symlink]}..."

		if [[ -d "/home/bsuth/${symlinks[$symlink]}" ]]; then
			rm -rf "/home/bsuth/${symlinks[$symlink]}"
		fi

		if ! ln -sfn "/home/bsuth/$symlink" "/home/bsuth/${symlinks[$symlink]}" 2>/dev/null; then
			echo "${RED}failed${NC}"
			(( failedsymlinks+=1 ))
		else
			echo "${GREEN}done${NC}"
		fi
	done

	if [[ $failedsymlinks > 0 ]]; then
		echo
		echo "${RED}Failed to create $failedsymlinks symlinks${NC}"
		_prompt_continue_
	else
		status=0
	fi
}

echo -e "${GREEN}=== Setting up symlinks ===${NC}\n"
_setup_symlinks_
_report_status_

# COMPLETE
echo -e "${GREEN}=== COMPLETE ===${NC}\n"
echo "Reboot computer for changes to take full effect."
echo
