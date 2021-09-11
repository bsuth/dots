#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Notes
#
# 1) Creating a new user
#   useradd -m -d /home/bsuth -s /bin/zsh -G sudo bsuth 
#   passwd bsuth
# 2) Creating the sudo group
#   groupadd sudo
# 3) Add user to sudoers by uncommenting following line in /etc/sudoers
#   %sudo ALL=(ALL) ALL
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Setup
# ------------------------------------------------------------------------------

set -e
DOTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)"

if [[ $UID == 0 ]]; then
  echo "${RED}This script cannot be run as root.${NC}"
  exit 1
fi

echo

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
  ./configure --with-lua-include=/usr/local/include
  make
  make install
  sudo luarocks install "${LUAROCKS_PACKAGES[@]}"
  cd -
}

echo -e "${GREEN}=== Packages ===${NC}\n"
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
    ["$DOTS/bin"]=".local/bin"
    ["$DOTS/.zshrc"]=".zshrc"
    ["$DOTS/.zprofile"]=".zprofile"
    ["$DOTS/awesome"]=".config/awesome"
    ["$DOTS/nvim"]=".config/nvim"
  )

  for SYMLINK in ${!SYMLINKS[@]}; do
    printf "${SYMLINK} -> ~/${SYMLINKS[$SYMLINK]}"

    if [[ -d "$HOME/${SYMLINKS[$SYMLINK]}" ]]; then
      rm -rf "$HOME/${SYMLINKS[$SYMLINK]}"
    fi

    ln -sfn "$SYMLINK" "$HOME/${SYMLINKS[$SYMLINK]}" 2>/dev/null
  done
}

echo -e "${GREEN}=== Symlinks ===${NC}\n"
_setup_symlinks_

# ------------------------------------------------------------------------------
# Services
# ------------------------------------------------------------------------------

function _setup_services_() {
  declare -A services=(
    "physlock.service"
  )

  for service in ${!services[@]}; do
    printf "$DOTS/${service} -> /etc/systemd/system/${services[$service]}"

    if [[ -d "$HOME/${services[$service]}" ]]; then
      rm -rf "$HOME/${services[$service]}"
    fi

    sudo ln -sfn "$DOTS/${service}" "/etc/systemd/system/${services[$service]}" 2>/dev/null
    systemctl enable "$service"
  done

  systemctl daemon-reload
}

echo -e "${GREEN}=== Services ===${NC}\n"
_setup_services_

# ------------------------------------------------------------------------------
# Complete
# ------------------------------------------------------------------------------

echo -e "${GREEN}=== Complete ===${NC}\n"
echo "The following need to be setup manually:"
echo "1) Firefox profile / userChrome"
echo
