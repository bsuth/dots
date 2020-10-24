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

function _prompt_continue_() {
	if ! _yesno_ "Continue?"; then
		status=1; _report_status_
		exit 0
	else
		status=2
	fi
}

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------

if [[ $UID != 0 ]]; then
	echo "${RED}This script must be run as root.${NC}"
	exit 1
fi

echo

## Setup services ## 

function _setup_services_() {
	services=(
		systemd-networkd
		systemd-resolved
	)

	for service in ${services[@]}; do
		systemctl enable "$service.service"
		systemctl start "$service.service"
	done

	status=0
}

echo -e "${GREEN}=== Setting up services ===${NC}"
_setup_services_
_report_status_

## Setup Wifi ## 

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
					echo -e "[Match]\nName=$interface\n[Network]\nDHCP=yes" > /etc/systemd/network/1-wireless.network
					systemctl restart "systemd-networkd.service" >/dev/null 2>&1
					echo "${GREEN}done${NC}"

					while : ; do
						printf "Checking connection..."

						# Give some time for the network to connect
						sleep 2

						if ping -c 1 8.8.8.8 -W 50 >/dev/null 2>&1; then
							echo "${GREEN}done${NC}"
							status=0
							return
						fi

						echo "${RED}failed${NC}"
						echo -e "\n${RED}Failed to ping 8.8.8.8${NC}"
						if ! _yesno_ "Try again?"; then
							if _yesno_ "Use anyways?"; then
								status=0
								return
							else
								break
							fi
						fi
					done

					printf "Configuration aborted. Reverting changes..."
					rm "/etc/wpa_supplicant/wpa_supplicant-${interface}.conf"
					systemctl stop "wpa_supplicant@${interface}.service" >/dev/null 2>&1
					systemctl disable "wpa_supplicant@${interface}.service" >/dev/null 2>&1
					echo "${GREEN}done${NC}"

					if ! _yesno_ "Try different credentials?"; then
						status=1
						break
					fi
				else
					echo "${RED}Invalid parameters (wpa_passphrase returned non-zero exit status)${NC}"
					status=1
					if ! _yesno_ "Try again?"; then break; fi
				fi
			done
		fi
	done

	echo -e "\n${RED}Error: Failed to find WLAN interface.${NC}"

	_prompt_continue_
}

echo -e "${GREEN}=== Setting up wifi ===${NC}\n"
_setup_wifi_
_report_status_

## Install Packages ## 

function _install_packages_() {
	declare -a packages=(
		# System
		sudo
		xorg
		pulseaudio
		udisks2
		udiskie 
		acpi
		brightnessctl

		# Utilities
		curl
		pass
		physlock
		fd-find
		fzf
		ripgrep
		flameshot
		deepin-image-viewer

		# Development
		make
		cmake
		pkg-config
		clang
		nodejs
		npm
		luajit
		libluajit-5.1-dev

		# Environment
		chromium
		papirus-icon-theme
		zsh
		compton
	)

	if ! _yesno_ "Install packages?"; then status=2; return; fi

	while : ; do
		if apt install "${packages[@]}"; then
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

## Update sudoers ## 

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

## Setup symlinks ## 

function _setup_symlinks_() {
	declare -A symlinks=(
		["/usr/bin/luajit"]="/usr/bin/lua"
	)

	failedsymlinks=0

	for symlink in ${!symlinks[@]}; do
		printf "Linking ${symlink} -> ${symlinks[$symlink]}..."
		if ! ln -sfn "$symlink" "${symlinks[$symlink]}" 2>/dev/null; then
			echo "${RED}failed${NC}"
			(( failedsymlinks+=1 ))
		else
			echo "${GREEN}done${NC}"
		fi
	done

	if [[ $failedsymlinks > 0 ]]; then
		echo
		echo "${RED}Failed to create $failedsymlinks symlinks${NC}"
		_prompt_continue_
	else
		status=0
	fi
}

echo -e "${GREEN}=== Setting up symlinks ===${NC}\n"
_setup_symlinks_
_report_status_
