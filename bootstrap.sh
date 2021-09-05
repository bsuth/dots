#!/bin/bash

# ------------------------------------------------------------------------------
# NOTES
#
# 1) Creating a new user
#   useradd -m -d /home/bsuth -s /bin/zsh -G sudo bsuth 
#   passwd bsuth
# 2) Creating the sudo group
#   groupadd sudo
# 3) Add user to sudoers by uncommenting following line in /etc/sudoers
#   %sudo ALL=(ALL) ALL
# ------------------------------------------------------------------------------

# This script's parent directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

#
# Install Packages
#

function _install_packages_() {
  if ! _yesno_ "Install packages?"; then status=2; return; fi

  declare -a pacman_packages=(
    # System
    amd-ucode
    efibootmgr
    lvm2
    xorg-server
    xorg-xinit
    xorg-xev
    iwd
    bluez
    bluez-utils
    alsa-utils
    pulseaudio
    pulseaudio-alsa
    pulseaudio-bluetooth
    upower

    # Languages
    luajit
    nodejs
    npm
    rust
    go
    python3
    python-pip

    # Input / Fonts
    fcitx5
    fcitx5-mozc
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-qt
    adobe-source-han-sans-jp-fonts

    # Tools
    base-devel
    git
    openssh
    zsh
    zip
    unzip
    flameshot
    ripgrep
    fd
    physlock
    brightnessctl
    clang

    # Apps
    neovim
    firefox-developer-edition
    arandr
    inkscape
  )
  pacman -Syu "${pacman_packages[@]}"

  declare -a python_packages=(
    pynvim
  )
  pip install "${python_packages[@]}"

  status=0
}

echo -e "${GREEN}=== Installing packages ===${NC}\n"
_install_packages_
_report_status_

#
# Install AUR Packages
#

function _install_aur_packages_() {
  if ! _yesno_ "Install AUR packages?"; then status=2; return; fi

  declare -a pacman_packages=(
    awesome-luajit
  )

  RESTORE_DIR="$(pwd)"
  mkdir -p "$HOME/packages"
  cd "$HOME/packages"

  for PKG in ${!pacman_packages[@]}; do
    git clone "https://aur.archlinux.org/${PKG}.git"
    cd "$PKG"
    makepkg -si
    cd -
  done

  cd "$RESTORE_DIR"
}

echo -e "${GREEN}=== Installing AUR packages ===${NC}\n"
_install_aur_packages_
_report_status_

#
# Install Luarocks Packages
#

function _install_luarocks_packages_() {
  if ! _yesno_ "Install Luarocks packages?"; then status=2; return; fi

  declare -a luarocks_packages=(
    lpeg
    luafilesystem
    lua-cjson
    busted
  )

  RESTORE_DIR="$(pwd)"
  mkdir -p "$HOME/packages"
  cd "$HOME/packages"

  git clone git://github.com/luarocks/luarocks.git
  cd luarocks

  ./configure --with-lua-include=/usr/local/include
  make
  make install

  luarocks install "${python_packages[@]}"

  cd "$RESTORE_DIR"
}

echo -e "${GREEN}=== Installing Luarocks packages ===${NC}\n"
_install_aur_packages_
_report_status_

#
# Setup Symlinks
#

function _setup_symlinks_() {
  declare -A symlinks=(
  ["Documents/ssh"]=".ssh"
  ["Documents/gnupg"]=".gnupg"
  ["Documents/password-store"]=".password-store"
  ["dots/bin"]=".local/bin"
  ["dots/.zshrc"]=".zshrc"
  ["dots/.zprofile"]=".zprofile"
  ["dots/awesome"]=".config/awesome"
  ["dots/nvim"]=".config/nvim"
)

if ! _yesno_ "Setup symlinks?"; then status=2; return; fi
failedsymlinks=0

for symlink in ${!symlinks[@]}; do
  printf "Linking ~/${symlink} -> ~/${symlinks[$symlink]}..."

  if [[ -d "$HOME/${symlinks[$symlink]}" ]]; then
    rm -rf "$HOME/${symlinks[$symlink]}"
  fi

  if ! ln -sfn "$HOME/$symlink" "$HOME/${symlinks[$symlink]}" 2>/dev/null; then
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

#
# Complete
#

echo -e "${GREEN}=== Complete ===${NC}\n"
echo "The following need to be setup manually:"
echo "1) Firefox profile / userChrome"
echo "2) luarocks"
echo "3) awesome-luajit (AUR)"
echo
