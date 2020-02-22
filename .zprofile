# ----------------------------------------------------
# PATH
# ----------------------------------------------------

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH so it includes rust packages
if [ -d "$HOME/.cargo/bin" ]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi


# ----------------------------------------------------
# ENVIRONMENT
# ----------------------------------------------------

export SHELL="/bin/zsh"
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"

export DOTS_CORE="$HOME/dots/core"
export DOTS_HOME="$HOME/dots/home"
export DOTS_WORK="$HOME/dots/work"
export SCRIPTS_CORE="$DOTS_CORE/scripts"

# fcitx variables
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"


# vim:syntax=sh
