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

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

RESTORE_DIR="$(pwd)"
echo

if ! command -v nvim &> /dev/null; then
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

	echo -e "${GREEN}=== Installing dependencies ===${NC}\n"
    	sudo apt install "${dependencies[@]}" 
	echo

	if ! [[ -d $HOME/tools/neovim ]]; then
		echo -e "${GREEN}=== Cloning repo ===${NC}\n"
		cd $HOME/tools
		git clone https://github.com/neovim/neovim
	fi
fi

cd $HOME/tools/neovim

echo -e "${GREEN}=== Building ===${NC}\n"

if _yesno_ "Pull and make install?"; then
	git checkout -b origin/stable
	git pull
	sudo make CMAKE_BUILD_TYPE=Release install
fi

cd $RESTORE_DIR
