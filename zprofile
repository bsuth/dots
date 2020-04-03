# ----------------------------------------------------
# PATH
# ----------------------------------------------------

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi


# ----------------------------------------------------
# ENVIRONMENT
# ----------------------------------------------------

export SHELL="/bin/zsh"
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"

export DOTS="$HOME/dots"
export SCRIPTS_CORE="$DOTS_CORE/scripts"

# fcitx variables
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

# run startx on login
if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi


# vim:syntax=sh
