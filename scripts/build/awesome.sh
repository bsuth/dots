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
echo

if ! command -v awesome &> /dev/null; then
	# https://packages.debian.org/buster/awesome
	dependencies=(
		dbus-x11
		gir1.2-freedesktop
		gir1.2-gdkpixbuf-2.0
		gir1.2-glib-2.0
		gir1.2-pango-1.0
		libc6
		libcairo-gobject2
		libcairo2
		libdbus-1-3
		libgdk-pixbuf2.0-0
		libglib2.0-0
		liblua5.3-0
		libstartup-notification0
		libx11-6
		libxcb-cursor0
		libxcb-icccm4
		libxcb-keysyms1
		libxcb-randr0
		libxcb-render0
		libxcb-shape0
		libxcb-util0
		libxcb-xinerama0
		libxcb-xkb1
		libxcb-xrm0
		libxcb-xtest0
		libxcb1
		libxdg-basedir1
		libxkbcommon-x11-0
		libxkbcommon0
		lua-lgi
		menu
	)

	echo -e "${GREEN}=== Installing dependencies ===${NC}\n"
	sudo apt install "${dependencies[@]}"
	echo

	if ! [[ -d $HOME/tools/awesome ]]; then
		echo -e "${GREEN}=== Fetching source files ===${NC}\n"
		wget "https://github.com/awesomeWM/awesome-releases/raw/master/awesome-$VERSION.tar.bz2"
		tar --extract --bzip2 --file="awesome-$VERSION.tar.bz2"
		rm "awesome-$VERSION.tar.bz2"
	fi
fi

echo -e "${GREEN}=== Installing / Uninstalling ===${NC}\n"

if _yesno_ "Build + install awesome?"; then
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
	sudo dpkg -i "awesome-$VERSION.deb"
elif _yesno_ "Uninstall awesome?"; then
	sudo apt purge awesome
fi

cd $RESTORE_DIR
