# ----------------------------------------------------
# ENVIRONMENT
# ----------------------------------------------------

export SHELL="/bin/zsh"
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"

export DOTS="$HOME/dots"

export HISTFILE=~/.histfile
export HISTSIZE=1000
export SAVEHIST=1000

export LC_ALL=en_US.UTF-8

export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export QT5_IM_MODULE=fcitx
export QT_QPA_PLATFORMTHEME=qt5ct

# ----------------------------------------------------
# STARTUP
# ----------------------------------------------------

# run startx on login
if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi

# vim: syntax=sh
