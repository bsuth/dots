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
cd $HOME/tools

echo -e "\n${GREEN}=== Installation ===${NC}\n"

if ! command -v awesome &> /dev/null; then
	echo "${RED}awesome executable not found${NC}"
	if ! _yesno_ "Install awesome?"; then exit 0; fi
	echo

	# apt-cache showsrc awesome
	dependencies=(
		imagemagick
		libcairo2-dev
		libdbus-1-dev
		libgdk-pixbuf2.0-dev
		libglib2.0-dev
		libpango1.0-dev
		libstartup-notification0-dev
		libx11-xcb-dev
		libxcb-cursor-dev
		libxcb-icccm4-dev
		libxcb-keysyms1-dev
		libxcb-randr0-dev
		libxcb-shape0-dev
		libxcb-util0-dev
		libxcb-xinerama0-dev
		libxcb-xkb-dev
		libxcb-xrm-dev
		libxcb-xtest0-dev
		libxdg-basedir-dev
		libxkbcommon-dev
		libxkbcommon-x11-dev
		x11proto-core-dev
		libgirepository1.0-dev # required for lgi
	)

	sudo apt install "${dependencies[@]}"
	echo

	if ! command -v luarocks; then
		echo "${RED}luarocks must be installed to install lgi${NC}"
		exit 0
	else
		sudo luarocks install lgi
	fi

	if ! [[ -d $HOME/tools/awesome-$VERSION ]]; then
		wget "https://github.com/awesomeWM/awesome-releases/raw/master/awesome-$VERSION.tar.bz2"
		tar --extract --bzip2 --file="awesome-$VERSION.tar.bz2"
		rm "awesome-$VERSION.tar.bz2"
	fi

	if ! [[ -d $HOME/tools/awesome-$VERSION/build ]]; then
		mkdir -p $HOME/tools/awesome-$VERSION/build
	fi

	cd $HOME/tools/awesome-$VERSION/build

	cmake .. \
		-DCMAKE_BUILD_TYPE=RELEASE \
		-DLUA_INCLUDE_DIR=/usr/include/luajit-2.1 \
		-DLUA_LIBRARY=/usr/lib/i386-linux-gnu/libluajit-5.1.so.2 \
		-DGENERATE_DOC=OFF
	make package
	sudo dpkg -i *.deb
else
	echo "${GREEN}awesome executable found${NC}"
	if _yesno_ "Uninstall awesome?"; then
		sudo apt purge awesome
		[[ -d $HOME/tools/awesome-$VERSION ]] && rm -rf $HOME/tools/awesome-$VERSION
	fi
fi

cd $RESTORE_DIR
