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
    # Auto-mount usbs
    udisks2
    udiskie 

    # Network
    iwd
    dhcpcd5

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
    papirus-icon-theme
    compton
    physlock
    pass
    zsh
    vifm
)

apt install "${PACKAGES[@]}"
