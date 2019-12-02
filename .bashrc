#!/bin/bash

# -------------------------------------------------------------------
# NECESSITIES
# -------------------------------------------------------------------

# If not running interactively, don't do anything. This is needed
# for rcp, scp, and sftp protocols. Link for in-depth explanation:
# https://unix.stackexchange.com/questions/257571/why-does-bashrc-check-whether-the-current-shell-is-interactive
case $- in
    *i*) ;;
      *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS. Without this, terminal
# rendering may have problems upon resizing.
shopt -s checkwinsize


# -------------------------------------------------------------------
# OPTIONAL
# -------------------------------------------------------------------

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# enable color support of common builtins
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# -------------------------------------------------------------------
# HISTORY
# -------------------------------------------------------------------

# On duplicates, erase all previous instances of the command.
# Ignore all lines starting with space.
export HISTCONTROL=ignorespace:erasedups

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export HISTFILESIZE=2000


# -------------------------------------------------------------------
# SOURCES
# -------------------------------------------------------------------

# fzf setup
[ -f $HOME/.fzf.bash ] && source $HOME/.fzf.bash
export FZF_DEFAULT_COMMAND="
    find . \( \
        -path '*/env' -o \
        -path '*/.npm' -o \
        -path '*/.cache' -o \
        -path '*/.local' -o \
        -path '*/node_modules' -o \
        -path '*/.git' -o \
        -path '*/.mozilla' \
    \) -prune -o -print
"

# Specific rc's
[ -f $DOTS_CORE/.aliases ] && source $DOTS_CORE/.aliases
[ -f $DOTS_HOME/homerc ] && source $DOTS_HOME/homerc
[ -f $DOTS_WORK/workrc ] && source $DOTS_WORK/workrc 

# Starship Prompt
eval "$(starship init bash)"

# Pip: Generated via `pip3 completion --bash`
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip3


# -------------------------------------------------------------------
# KEYBINDINGS (see `man bash`: SHELL BUILTIN COMMANDS -> bind)
# -------------------------------------------------------------------

# Clear screen
# bind -m vi-insert "\C-l":clear-screen
# bind -m vi "\C-l":clear-screen
bind -x '"\C-r":_reverse_search_'
