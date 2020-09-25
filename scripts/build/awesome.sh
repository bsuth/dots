#!/bin/bash

RESTORE_DIR="$(pwd)"

if ! command -v awesome &> /dev/null; then
    # Missing from `apt build-dep awesome`
    DEPENDENCIES=(
	libxcb-xfixes0-dev
    )

    sudo apt build-dep awesome
    sudo apt install "${DEPENDENCIES[@]}"
fi

if ! [[ -d $HOME/tools/awesomewm ]]; then
    mkdir -p $HOME/tools
    cd $HOME/tools
    git clone https://github.com/awesomeWM/awesome
fi

cd $HOME/tools/awesome
git pull
sudo make install

cd $RESTORE_DIR
