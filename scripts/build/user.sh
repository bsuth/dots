#!/bin/bash

# ------------------------------------------------------------------------------
# README
#
# This is a script to setup my daily driver environment on a machine. It assumes
# that the current user is `bsuth`.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ANSI COLOR CODES
# ------------------------------------------------------------------------------

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
            y) return 0 ;;
            n) return 1 ;;
            *) echo -e "${RED}Invalid input${NC}\n"
        esac
    done
}

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

if [[ $UID == 0 ]]; then
    echo "${RED}This script cannot be run as root.${NC}"
    exit 1
fi

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}========== User Setup ==========${NC}"
echo -e "${GREEN}================================${NC}\n"

# --------------------------------------
# Create Home Folders
# --------------------------------------

echo -e "${GREEN}=== Creating home folders ===${NC}\n"
! [[ -d $HOME/.config ]] && mkdir $HOME/.config
! [[ -d $HOME/tools ]] && mkdir $HOME/tools

# --------------------------------------
# Clone Dots Repo
# --------------------------------------

echo -e "${GREEN}=== Cloning dots repo ===${NC}\n"
cd $HOME; git clone https://github.com/bsuth/dots.git; cd $HOME/dots

# --------------------------------------
# Setup Symbolic Links
#
# Note: Use absolute paths here, since custom environment variables will not be
# setup yet (zprofile not loaded).
# --------------------------------------

echo -e "${GREEN}=== Setting up symbolic links ===${NC}\n"

ln -sf "$HOME/dots/Xmodmap" "$HOME/.Xmodmap"
ln -sf "$HOME/dots/xinitrc" "$HOME/.xinitrc"

ln -sf "$HOME/dots/zsh/zprofile" "$HOME/.zprofile"
ln -sf "$HOME/dots/zsh/zshrc" "$HOME/.zshrc"

ln -sfn "$HOME/dots/awesome" "$HOME/.config/awesome"

ln -sfn "$HOME/dots/nvim" "$HOME/.config/nvim"

ln -sfn "$HOME/dots/vifm" "$HOME/.config/vifm"

ln -sf "$HOME/dots/picom.conf" "$HOME/.config/picom.conf"

sudo ln -sf "$HOME/dots/services/physlock.service" "/etc/systemd/system/physlock.service"

# --------------------------------------
# Change Shell
# --------------------------------------

echo -e "${GREEN}=== Changing user shell to zsh ===${NC}\n"
sudo chsh -s /bin/zsh bsuth
