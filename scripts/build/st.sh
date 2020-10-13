#!/bin/bash

# ------------------------------------------------------------------------------ 
# README
# This is a script to build and install my fork of st.
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
cd $HOME/tools
echo

if ! command -v st &> /dev/null; then
	if ! [[ -d $HOME/tools/st ]]; then
		echo -e "${GREEN}=== Cloning repo ===${NC}\n"
		git clone https://github.com/bsuth/st.git
		echo
	fi
fi

cd $HOME/tools/st

echo -e "${GREEN}=== Installing / Uninstalling ===${NC}\n"

if _yesno_ "Build + install st?"; then
	make
	sudo make install
elif _yesno_ "Uninstall luarocks?"; then
	sudo make uninstall
fi

cd $RESTORE_DIR
