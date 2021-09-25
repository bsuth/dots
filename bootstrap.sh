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
# 4) Change default shell
#   chsh -s /bin/zsh bsuth
# 5) Create systemd-networkd config file at /etc/systemd/network/1-wireless.network
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
# 1) Enable services
#   - systemd-networkd
#   - systemd-resolved
#   - iwd
#   - bluetooth
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
    xf86-video-amdgpu # AMD
    # xf86-video-intel # Intel
    xorg-server
    xorg-xinit
    xorg-xev
    xclip
    awesome
    picom

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
    fcitx5-im
    fcitx5-mozc
    adobe-source-han-sans-jp-fonts
    ttf-hack

    # Tools
    reflector
    base-devel
    man-db
    git
    openssh
    zsh
    zip
    unzip
    ripgrep
    fd
    fzf
    brightnessctl
    clang

    # Apps
    flameshot
    gpick
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
    ldoc
    lpeg
    luafilesystem
    lua-cjson
    busted
    inspect
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
      if ! luarocks --local --lua-version="$LUA_VERSION" show "$PACKAGE"; then
	      echo "luarocks --local --lua-version="$LUA_VERSION" show "$PACKAGE""
        luarocks --local --lua-version="$LUA_VERSION" install "$PACKAGE"
      fi
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
    ["$DOTS/awesome"]=".config/awesome"
    ["$DOTS/nvim"]=".config/nvim"
    ["$DOTS/.xinitrc"]=".xinitrc"
    ["$DOTS/.zprofile"]=".zprofile"
    ["$DOTS/.zshrc"]=".zshrc"
  )

  for SYMLINK in ${!SYMLINKS[@]}; do
    echo "$SYMLINK -> ~/${SYMLINKS[$SYMLINK]}"
    if [[ -d "$HOME/${SYMLINKS[$SYMLINK]}" ]]; then
      rm -rf "$HOME/${SYMLINKS[$SYMLINK]}"
    fi
    mkdir -p $(dirname "$HOME/${SYMLINKS[$SYMLINK]}")
    ln -sfn "$SYMLINK" "$HOME/${SYMLINKS[$SYMLINK]}"
  done

  declare -A DEEP_SYMLINKS=(
    ["$DOTS/bin"]=".local/bin"
  )

  for SYMLINK_DIR in ${!DEEP_SYMLINKS[@]}; do
    for FILE in $SYMLINK_DIR/*; do
      if [[ -x $FILE ]]; then
        echo "$FILE -> ~/${DEEP_SYMLINKS[$SYMLINK_DIR]}"
	      mkdir -p "$HOME/${DEEP_SYMLINKS[$SYMLINK_DIR]}"
        ln -sf "$FILE" "$HOME/${DEEP_SYMLINKS[$SYMLINK_DIR]}"
      fi
    done
  done
}

echo -e "${GREEN}=== Symlinks ===${NC}"
_setup_symlinks_

# ------------------------------------------------------------------------------
# ST Terminal
# ------------------------------------------------------------------------------

function _setup_st_() {
  if ! command -v st; then
    cd "$DOTS/st"
    make
    sudo make install
    cd $DOTS
  fi
}

echo -e "${GREEN}=== ST Terminal ===${NC}"
_setup_st_


# ------------------------------------------------------------------------------
# Complete
# ------------------------------------------------------------------------------

echo -e "${GREEN}=== Complete ===${NC}\n"
echo "The following need to be setup manually:"
echo "1) Firefox: profile / userChrome / surfingkeys"
echo "2) Services (physlock)"
