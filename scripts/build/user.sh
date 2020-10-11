#!/bin/bash

# ------------------------------------------------------------------------------
# README
#
# This is a script to setup my daily driver environment on a machine. It assumes
# that the current user is `bsuth`.
# ------------------------------------------------------------------------------

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
            y) return 0 ;;
            n) return 1 ;;
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

if [[ $UID == 0 ]]; then
    echo "${RED}This script cannot be run as root.${NC}"
    exit 1
fi

cd $HOME; 
echo # Newline for readability

## Create Home Folders ##

function _create_dirs_() {
	declare -a directories=(
		.config
		tools
	)

	declare -a failed=()

	for directory in ${directories[@]}; do
		if ! [[ -d $directory ]]; then
			printf "Creating ~/$directory..."
			if ! mkdir -p "$HOME/$directory"; then
				printf "${RED}failed${NC}"
				failed+=($directory)
			else
				echo "${GREEN}done${NC}"
			fi
		else
			echo "Found $directory"
		fi
	done

	if [[ ${#failed[@]} > 0 ]]; then
		echo "${RED}Failed to create the following directories:${NC}"
		for directory in ${failed[@]}; do
			echo "${RED}$directory${NC}"
		done
		_prompt_continue_
	else
		status=0
	fi
}

echo -e "${GREEN}=== Creating directories ===${NC}\n"
_create_dirs_
_report_status_

## Setup dots ##

function _setup_dots_() {
	if ! [[ -d $HOME/dots ]]; then
		printf "Cloning repo..."
		if ! git clone https://github.com/bsuth/dots.git >/dev/null 2>&1; then
			echo "${RED}failed${NC}"
			_prompt_continue_
		else
			echo "${GREEN}done${NC}"
		fi
	else
		printf "Found dots directory. Pulling..."
		cd $HOME/dots

		if ! git pull >/dev/null 2>&1; then
			echo "${RED}failed${NC}"
			_prompt_continue_
		else
			echo "${GREEN}done${NC}"
		fi

		cd $HOME
	fi

	echo

	declare -A symlinks=(
		["Xmodmap"]=".Xmodmap"
		["xinitrc"]=".xinitrc"
		["zsh/zprofile"]=".zprofile"
		["zsh/zshrc"]=".zshrc"
		["awesome"]=".config/awesome"
		["nvim"]=".config/nvim"
		["picom.conf"]=".config/picom.conf"
	)

	declare -A sudosymlinks=(
		["services/physlock.service"]="/etc/systemd/system/physlock.service"
	)

	failedsymlinks=0

	for symlink in ${!symlinks[@]}; do
		printf "Linking ~/dots/${symlink} -> ~/${symlinks[$symlink]}..."
		if ! ln -sfn "$HOME/dots/$symlink" "$HOME/${symlinks[$symlink]}" 2>/dev/null; then
			echo "${RED}failed${NC}"
			(( failedsymlinks+=1 ))
		else
			echo "${GREEN}done${NC}"
		fi
	done

	echo
	echo "sudo required for system-level symlinks"
	sudo echo ""

	for symlink in ${!sudosymlinks[@]}; do
		printf "Sudo linking ~/dots/$symlink -> ${sudosymlinks[$symlink]}..."
		if ! sudo ln -sfn "$HOME/dots/$symlink" "${sudosymlinks[$symlink]}" 2>/dev/null; then
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

echo -e "${GREEN}=== Setting up dots ===${NC}\n"
_setup_dots_
_report_status_

## Change Shell ##

function _change_shell_() {
	printf "Changing shell for bsuth to zsh..."
	if ! sudo chsh -s /bin/zsh bsuth; then
		echo "${GREEN}failed${NC}"
		_prompt_continue_
	else
		echo "${GREEN}done${NC}"
		status=0
	fi
}

echo -e "${GREEN}=== Changing shell ===${NC}\n"
_change_shell_
_report_status_

## Configure git ##

function _configure_git_() {
	printf "Configuring git..."

	git config --global pull.rebase false
	git config --global user.name 'bsuth'
	git config --global user.email 'bsuth701@gmail.com'

	echo "${GREEN}done${NC}"
	status=0
}

echo -e "${GREEN}=== Configuring git ===${NC}\n"
_configure_git_
_report_status_

## Neovim ##

# ./neovim.sh
