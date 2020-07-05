# ----------------------------------------------------
# PATH
# ----------------------------------------------------

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

export PATH="$DOTS/scripts:$PATH"

# ----------------------------------------------------
# ENVIRONMENT
# ----------------------------------------------------

export LC_ALL=en_US.UTF-8

export SHELL="/bin/zsh"
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"

export DOTS="$HOME/dots"
export SCRIPTS_CORE="$DOTS_CORE/scripts"

export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export QT5_IM_MODULE=fcitx
export QT_QPA_PLATFORMTHEME=qt5ct

# run startx on login
if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi

# vim:syntax=sh
