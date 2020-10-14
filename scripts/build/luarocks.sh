#!/bin/bash

# ------------------------------------------------------------------------------ 
# README
# This is a script to build and install luarocks using luajit.
# ------------------------------------------------------------------------------

# ANSI color codes
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)"

VERSION="3.3.1"

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

echo -e "${GREEN}=== Installing / Uninstalling ===${NC}\n"

if ! command -v luarocks &> /dev/null; then
	echo "${RED}luarocks executable not found${NC}"
	if ! _yesno_ "Install luarocks?"; then exit 0; fi
	echo

	dependencies=(
		build-essential
		libreadline-dev
	)

	sudo apt install "${dependencies[@]}"
	echo

	if ! [[ -d $HOME/tools/luarocks-$VERSION ]]; then
		echo -e "${GREEN}=== Fetching source files ===${NC}\n"
		wget "https://luarocks.org/releases/luarocks-$VERSION.tar.gz"
		tar --extract --gunzip --preserve-permissions --file="luarocks-$VERSION.tar.gz"
		rm "luarocks-$VERSION.tar.gz"
		echo
	fi

	cd $HOME/tools/luarocks-$VERSION
	./configure --with-lua-include=/usr/include/luajit-2.1
	make
	sudo make install
else
	echo "${GREEN}luarocks executable found${NC}"
	if _yesno_ "Uninstall luarocks?"; then
		sudo rm -rf /usr/local/bin/luarocks* /usr/local/lib/luarocks
		exit 0
	fi
fi

# cd to ensure we use the system-level executable
# (over the locally built one in the tools/luarocks repo)
cd $HOME 
echo -e "\n${GREEN}=== Installing rocks ===${NC}\n"

if _yesno_ "Install standard rocks?"; then
	rocks=(
		lua-cjson
		busted
		luafilesystem
	)

	for rock in "${rocks[@]}"; do
		sudo luarocks install "$rock"
	done
fi

cd $RESTORE_DIR
