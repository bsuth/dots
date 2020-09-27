#!/bin/bash

# ------------------------------------------------------------------------------
# README

# This is a script to setup my daily driver environment on a machine. It assumes
# that the current user is `root`.
# ------------------------------------------------------------------------------

# Status
status=0

# ANSI color codes
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)"

# ------------------------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------------------------

function _report_status_() {
    case $status in
	0) echo -e "\n${GREEN}--> Success! <--${NC}\n" ;;
	1) echo -e "\n${RED}--> Failed <--${NC}\n" ;;
	2|*) echo -e "\n${RED}--> Skipped <--${NC}\n" ;;
    esac	    
}

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

if [[ $UID != 0 ]]; then
    echo "${RED}This script must be run as root.${NC}"
    exit 1
fi

# Newline for readability
echo

# --------------------------------------
# Setup Wifi
# --------------------------------------

function _setup_wifi_() {
    if ! _yesno_ "Setup wifi?"; then status=2; return; fi

    # See here for a list of all interface prefixes:
    # https://www.freedesktop.org/software/systemd/man/systemd.net-naming-scheme.html
    found_interface=0

    for interface in $(ls /sys/class/net); do
        if [[ ${interface:0:2} == "wl" ]]; then
            echo -e "\nFound WLAN interface: $interface"
            if ! _yesno_ "Use this?"; then continue; fi 

	    while : ; do
		echo
                read -p "SSID: " ssid
                read -p "Password: " -s pass
		echo -e "\n"

		if wpa_passphrase "$ssid" "$pass" >/dev/null; then
		    printf "Saving configuration and setting up service..."
                    wpa_passphrase "$ssid" "$pass" > "/etc/wpa_supplicant/wpa_supplicant-${interface}.conf"
                    systemctl enable "wpa_supplicant@${interface}.service" >/dev/null 2>&1
                    systemctl restart "wpa_supplicant@${interface}.service" >/dev/null 2>&1
		    echo "${GREEN}done${NC}"

		    while : ; do
		        printf "Checking connection..."

			# Give some time for the network to connect
			sleep 2

		        if ping -c 1 8.8.8.8 -W 10 >/dev/null 2>&1; then
		    	    echo "${GREEN}done${NC}"
		            status=0
		            return
		        fi
    
		    	echo "${RED}failed${NC}"
		        echo -e "\n${RED}Failed to ping 8.8.8.8${NC}"
		    	if ! _yesno_ "Try again?"; then break; fi
		    done

		    echo
		    printf "Configuration aborted. Reverting changes..."
                    rm "/etc/wpa_supplicant/wpa_supplicant-${interface}.conf"
                    systemctl stop "wpa_supplicant@${interface}.service" >/dev/null 2>&1
                    systemctl disable "wpa_supplicant@${interface}.service" >/dev/null 2>&1
		    echo "${GREEN}done${NC}"

		    if ! _yesno_ "Try different credentials?"; then break; fi
		else
		    echo "${RED}Invalid parameters (wpa_passphrase returned non-zero exit status)${NC}"
		    if ! _yesno_ "Try again?"; then break; fi
		fi
	    done
        fi
    done

    echo -e "\n${RED}Error: Failed to find WLAN interface.${NC}"

    if ! _yesno_ "Continue?"; then
	status=1; _report_status_
	exit 0
    else
	status=2
    fi
}

echo -e "${GREEN}=== Setting up wifi ===${NC}\n"
_setup_wifi_
_report_status_

# --------------------------------------
# Install Packages
# --------------------------------------

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

function _install_packages_() {
    if ! _yesno_ "Install packages?"; then status=2; return; fi

    while : ; do
        if apt install "${PACKAGES[@]}"; then
	    status=0
	    return
        else
	    if ! _yesno_ "Try again?"; then break; fi
        fi
    done

    status=2
}

echo -e "${GREEN}=== Installing packages ===${NC}\n"
_install_packages_
_report_status_

# --------------------------------------
# Update sudoers
# --------------------------------------

function _setup_sudoers_() {
    if usermod -a -G sudo bsuth; then
        status=0
    else
        status=1
    fi
}

echo -e "${GREEN}=== Adding bsuth to sudoers ===${NC}"
_setup_sudoers_
_report_status_
