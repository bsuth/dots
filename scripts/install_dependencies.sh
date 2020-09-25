#!/bin/bash

# -------------------------------------------------------
# RUN AS ROOT
# Most of these commands require root priviledges to run,
# so we change permissions here so we don't have to write
# `sudo` a billion times.
# -------------------------------------------------------

[[ $UID == 0 ]] || exec sudo "$0" "$@"

# -------------------------------------------------------
# PACKAGES
# -------------------------------------------------------

PACKAGES=(
    # System
    xorg
    pulseaudio
    udisks2
    udiskie 

    # Utilities
    acpi
    fd-find
    fzf
    ripgrep

    # Development
    make
    pkg-config
    clang
    nodejs
    luajit
    luarocks

    # Environment
    awesome
    vifm
    pass
    zsh
    compton
    physlock
    papirus-icon-theme
)

apt install "${PACKAGES[@]}"
