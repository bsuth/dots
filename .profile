# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
#
# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	    . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi


# ----------------------------------------------------
# ENVIRONMENT
# ----------------------------------------------------

export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"

export DOTS_CORE="$HOME/dots/core"
export DOTS_HOME="$HOME/dots/home"
export DOTS_WORK="$HOME/dots/work"

export SCRIPTS_CORE="$DOTS_CORE/scripts"

# Ranger
export RANGER_LOAD_DEFAULT_RC=TRUE

# Other Environment Variables
export NOTES_DIR="$HOME/notes"

# fcitx variables
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"


# ----------------------------------------------------
# STARTUP
# ----------------------------------------------------

# Use fcitx as input method
# fcitx -d -r

# vim:syntax=sh
