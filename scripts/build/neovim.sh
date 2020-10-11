#!/bin/bash

RESTORE_DIR="$(pwd)"

if ! command -v nvim &> /dev/null; then
    DEPENDENCIES=(
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

    sudo apt install "${DEPENDENCIES[@]}"
fi

if ! [[ -d $HOME/tools/neovim ]]; then
    mkdir -p $HOME/tools
    cd $HOME/tools
    git clone https://github.com/neovim/neovim
fi

cd $HOME/tools/neovim
git checkout -b origin/stable
git pull
sudo make CMAKE_BUILD_TYPE=Release install

cd $RESTORE_DIR
