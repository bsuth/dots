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

function _update_st_() {
	cd $HOME/tools/st
	git pull
	make
	sudo make install
	cd - >/dev/null
}

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

RESTORE_DIR="$(pwd)"

echo -e "\n${GREEN}=== Installing / Uninstalling ===${NC}\n"

if ! command -v st &> /dev/null; then
	echo "${RED}st executable not found${NC}"
	if ! _yesno_ "Install st?"; then exit 0; fi
	echo

    dependencies=(
		libx11-dev
		libxft-dev
    )

    sudo apt install "${dependencies[@]}" 
	echo

	if ! [[ -d $HOME/tools/st ]]; then
		cd $HOME/tools
		git clone https://github.com/bsuth/st.git
		echo
	fi

	_update_st_
else
	echo "${GREEN}st executable found${NC}"

	if _yesno_ "Pull and remake st?"; then
		echo
		_update_st_
	elif _yesno_ "Uninstall st?"; then
		cd $HOME/tools/st
		sudo make uninstall
		[[ -d $HOME/tools/st ]] && rm -rf $HOME/tools/st
	fi
fi

cd $RESTORE_DIR
