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

if ! command -v luarocks &> /dev/null; then
	dependencies=(
		build-essential
		libreadline-dev
	)

	echo -e "${GREEN}=== Installing dependencies ===${NC}\n"
	sudo apt install "${dependencies[@]}"
	echo

	if ! [[ -d $HOME/tools/luarocks-$VERSION ]]; then
		echo -e "${GREEN}=== Fetching source files ===${NC}\n"
		wget "https://luarocks.org/releases/luarocks-$VERSION.tar.gz"
		tar --extract --gunzip --preserve-permissions --file="luarocks-$VERSION.tar.gz"
		rm "luarocks-$VERSION.tar.gz"
		echo
	fi
fi

cd $HOME/tools/luarocks-$VERSION

echo -e "${GREEN}=== Installing / Uninstalling ===${NC}\n"

if _yesno_ "Build + install luarocks?"; then
	./configure --with-lua-include=/usr/include/luajit-2.1
	make
	sudo make install
elif _yesno_ "Uninstall luarocks?"; then
	sudo rm -rf /usr/local/bin/luarocks* /usr/local/lib/luarocks
fi

echo -e "${GREEN}=== Installing packages ===${NC}\n"

if _yesno_ "Install standard rocks?"; then
	rocks=(
		lua-cjson
		busted
		luafilesystem
	)

	luarocks install "${rocks[@]}"
fi

cd $RESTORE_DIR
