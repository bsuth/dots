#!/bin/bash

# ------------------------------------------------------------------------------
# README
#
# This is a script to setup my daily driver environment on a machine. It assumes
# that the current user is `root`.
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

if [[ $UID != 0 ]]; then
    echo "${RED}This script must be run as root.${NC}"
    exit 1
fi

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}========== Global Setup ==========${NC}"
echo -e "${GREEN}==================================${NC}\n"

# --------------------------------------
# Install Packages
# --------------------------------------

echo -e "${GREEN}=== Installing packages ===${NC}\n"

PACKAGES=(
    # System
    xorg
    pulseaudio
    udisks2
    udiskie 

    # Utilities
    pass
    physlock
    acpi
    fd-find
    fzf
    ripgrep
    flameshot
    deepin-image-viewer

    # Development
    make
    pkg-config
    clang
    nodejs
    luajit
    luarocks

    # Environment
    awesome
    papirus-icon-theme
    vifm
    zsh
    compton
)

apt install "${PACKAGES[@]}"

# --------------------------------------
# Update sudoers
# --------------------------------------

echo -e "${GREEN}=== Adding bsuth to sudoers ===${NC}\n"
echo -e "Adding bsuth to sudoers\n"
addmod -a -G bsuth sudo

# --------------------------------------
# Setup Wifi
# --------------------------------------

echo -e "${GREEN}=== Setting up wifi ===${NC}\n"

if _yesno_ "Setup wifi?"; then
    # See here for a list of all interface prefixes:
    # https://www.freedesktop.org/software/systemd/man/systemd.net-naming-scheme.html

    for interface in "$(ls /sys/class/net)"; do
        if [[ ${interface:0:2} == "wl" ]]; then
            echo "Found WLAN interface: $interface"

            if __yesno__ "Use this?"; then
                printf "SSID: "; read $ssid
                printf "Password: "; read -s $pass
                wpa_passphrase "$ssid" "$pass" > "/etc/wpa_supplicant/wpa_supplicant-${interface}.conf"
                systemctl enable "wpa_supplicant@${interface}.service"
                systemctl start "wpa_supplicant@${interface}.service"
                break
            fi
        fi
    done
fi
