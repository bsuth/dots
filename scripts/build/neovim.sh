#!/bin/bash

# ------------------------------------------------------------------------------ 
# README
# This is a script to build and install neovim from the latest stable branch.
# ------------------------------------------------------------------------------

# ANSI color codes
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)"

# ------------------------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------------------------

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

function _update_nvim_() {
	cd $HOME/tools/neovim
	git checkout -b origin/stable 2>/dev/null
	git pull
	sudo make CMAKE_BUILD_TYPE=Release install
	cd - >/dev/null
}

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

RESTORE_DIR="$(pwd)"

echo -e "\n${GREEN}=== Installation ===${NC}\n"

if ! command -v nvim &> /dev/null; then
	echo "${RED}nvim executable not found${NC}"
	if ! _yesno_ "Install neovim?"; then exit 0; fi
	echo

    dependencies=(
        ninja-build
		gettext
		libtool
		libtool-bin
		autoconf
		cmake
		clang
		pkg-config
		unzip
    )

    sudo apt install "${dependencies[@]}" 
	echo

	if ! [[ -d $HOME/tools/neovim ]]; then
		cd $HOME/tools
		git clone https://github.com/neovim/neovim
		echo
	fi

	_update_nvim_
else
	echo "${GREEN}nvim executable found${NC}"
	if ! _yesno_ "Pull and remake neovim?"; then exit 0; fi
	echo
	_update_nvim_
fi

echo
cd $RESTORE_DIR
