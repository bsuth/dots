#!/bin/bash

# ------------------------------------------------------------------------------ 
# README
# This is a script to build and install awesome using luajit.
# ------------------------------------------------------------------------------

# ANSI color codes
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)"

VERSION="4.3"

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

if ! command -v awesome &> /dev/null; then
	echo -e "${GREEN}=== Installing dependencies ===${NC}\n"
	sudo apt build-dep awesome liblua5.3-0-

	if ! [[ -d $HOME/tools/awesome ]]; then
		echo -e "${GREEN}=== Fetching source files ===${NC}\n"
		wget "https://github.com/awesomeWM/awesome-releases/raw/master/awesome-$VERSION.tar.bz2"
		tar --extract --bzip2 --file="awesome-$VERSION.tar.bz2"
		rm "awesome-$VERSION.tar.bz2"
	fi
fi

echo -e "${GREEN}=== Installing / Uninstalling ===${NC}\n"

if _yesno_ "Build awesome?"; then
	cd $HOME/tools/awesome-$VERSION/build
	cmake .. \
		-DCMAKE_BUILD_TYPE=RELEASE \
		-DLUA_INCLUDE_DIR=/usr/include/luajit-2.0 \
		-DLUA_LIBRARY=/usr/lib/libluajit-5.1.so
	make package
	sudo dpkg -i "awesome-$VERSION.deb"
elif _yesno_ "Uninstall awesome?"; then
	sudo apt purge awesome
fi

cd $RESTORE_DIR
