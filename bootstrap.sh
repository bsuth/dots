#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Prereqs
#
# As root:
# 1) Creating a new user
#   useradd -m -d /home/bsuth -s /bin/zsh -G sudo bsuth 
#   passwd bsuth
# 2) Creating the sudo group
#   groupadd sudo
# 3) Add user to sudoers by uncommenting following line in /etc/sudoers
#   %sudo ALL=(ALL) ALL
# 4) Create systemd-networkd config file at /etc/systemd/network/1-wireless.network
#    https://wiki.archlinux.org/title/systemd-networkd#Wireless_adapter
#
#   Ex)
#    [Match]
#    Name=wlan0
#    
#    [Network]
#    DHCP=yes
# 
# As user:
# 1) Enable wifi services (systemd-networkd, systemd-resolved)
# 2) Restore Documents/ + symlinks
# 3) Install pass
# 4) Clone dots
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Setup
# ------------------------------------------------------------------------------

set -e
shopt -s nullglob

DOTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)"

if [[ $UID == 0 ]]; then
  echo "${RED}This script cannot be run as root.${NC}"
  exit 1
fi

# ------------------------------------------------------------------------------
# Packages
# ------------------------------------------------------------------------------

function _install_pacman_packages_() {
  declare -a PACMAN_PACKAGES=(
    # System
    amd-ucode
    efibootmgr
    lvm2
    upower

    # X11
    awesome
    xorg-server
    xorg-xinit
    xorg-xev

    # Wifi / Bluetooth
    iwd
    bluez
    bluez-utils

    # Audio
    alsa-utils
    pulseaudio
    pulseaudio-alsa
    pulseaudio-bluetooth

    # Lua
    lua51
    lua52
    lua53
    lua
    luajit

    # Languages
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
    reflector
    base-devel
    git
    openssh
    zsh
    zip
    unzip
    ripgrep
    fd
    brightnessctl
    clang

    # Apps
    flameshot
    physlock
    neovim
    firefox-developer-edition
    arandr
    inkscape
  )
  sudo pacman -Syu --needed "${PACMAN_PACKAGES[@]}"
}

function _install_pip_packages_() {
  declare -a PYTHON_PACKAGES=(
    pynvim
  )
  sudo pip install "${PYTHON_PACKAGES[@]}"
}

function _install_luarocks_packages_() {
  declare -a LUA_VERSIONS=(
    "5.1"
    "5.2"
    "5.3"
    "5.4"
  )

  declare -a LUAROCKS_PACKAGES=(
    lpeg
    luafilesystem
    lua-cjson
    busted
  )

  mkdir -p "$HOME/repos"
  if ! [[ -d $HOME/repos/luarocks ]]; then
    git clone git://github.com/luarocks/luarocks.git "$HOME/repos/luarocks"
  fi

  cd "$HOME/repos/luarocks"
  git pull
  for LUA_VERSION in ${LUA_VERSIONS[@]}; do
    ./configure --lua-version="$LUA_VERSION"
    make
    sudo make install
    for PACKAGE in ${LUAROCKS_PACKAGES[@]}; do
      sudo luarocks install "$PACKAGE"
    done
  done
  cd $DOTS
}

echo -e "${GREEN}=== Packages ===${NC}"
_install_pacman_packages_
_install_pip_packages_
_install_luarocks_packages_

# ------------------------------------------------------------------------------
# Symlinks
# ------------------------------------------------------------------------------

function _setup_symlinks_() {
  declare -A SYMLINKS=(
    ["$HOME/Documents/ssh"]=".ssh"
    ["$HOME/Documents/gnupg"]=".gnupg"
    ["$HOME/Documents/password-store"]=".password-store"
    ["$DOTS/.zshrc"]=".zshrc"
    ["$DOTS/.zprofile"]=".zprofile"
    ["$DOTS/awesome"]=".config/awesome"
    ["$DOTS/nvim"]=".config/nvim"
  )

  for SYMLINK in ${!SYMLINKS[@]}; do
    echo "$SYMLINK -> ~/${SYMLINKS[$SYMLINK]}"
    if [[ -d "$HOME/${SYMLINKS[$SYMLINK]}" ]]; then
      rm -rf "$HOME/${SYMLINKS[$SYMLINK]}"
    fi
    ln -sfn "$SYMLINK" "$HOME/${SYMLINKS[$SYMLINK]}"
  done

  declare -A DEEP_SYMLINKS=(
    ["$DOTS/bin"]=".local/bin"
  )

  for SYMLINK_DIR in ${!DEEP_SYMLINKS[@]}; do
    for FILE in $SYMLINK_DIR/*; do
      if [[ -x $FILE ]]; then
        echo "$SYMLINK_DIR/$FILE -> ~/${DEEP_SYMLINKS[$SYMLINK_DIR]}"
        ln -sf "$SYMLINK_DIR/$FILE" "$HOME/${SYMLINKS[$SYMLINK]}"
      fi
    done
  done
}

echo -e "${GREEN}=== Symlinks ===${NC}"
_setup_symlinks_

# ------------------------------------------------------------------------------
# Services
# ------------------------------------------------------------------------------

function _setup_services_() {
  declare -A SERVICES=(
    "physlock.service"
  )

  for SERVICE in ${SERVICES[@]}; do
    echo "$DOTS/${SERVICE} -> /etc/systemd/system/${SERVICE}"
    if [[ -d "$HOME/${SERVICE}" ]]; then
      rm -rf "$HOME/${SERVICE}"
    fi
    sudo ln -sfn "$DOTS/${SERVICE}" "/etc/systemd/system/${SERVICE}"
    systemctl enable "$SERVICE"
  done

  systemctl daemon-reload
}

echo -e "${GREEN}=== Services ===${NC}"
_setup_services_

# ------------------------------------------------------------------------------
# Complete
# ------------------------------------------------------------------------------

echo -e "${GREEN}=== Complete ===${NC}\n"
echo "The following need to be setup manually:"
echo "1) Firefox profile / userChrome"
