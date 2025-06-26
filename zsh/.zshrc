# ------------------------------------------------------------------------------
# Zsh
# ------------------------------------------------------------------------------

# Emacs Bindings
bindkey -e
bindkey \^U backward-kill-line

# Options
setopt appendhistory autocd extendedglob nomatch notify histignoredups
unsetopt beep

# Completion
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' matcher-list '' '' '' ''
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit; compinit

# ------------------------------------------------------------------------------
# Plugins
# ------------------------------------------------------------------------------

source $DOTS/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $DOTS/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $DOTS/zsh/H-S-MW/H-S-MW.plugin.zsh
source $DOTS/zsh/spaceship-prompt/spaceship.zsh

# ------------------------------------------------------------------------------
# Environment
#
# This should only include environment variables for interactive shells. All
# other environment variables should be placed in .zshenv
# ------------------------------------------------------------------------------

export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=1000
export SAVEHIST=1000

SPACESHIP_PROMPT_ORDER=(
  time          # Time stamps section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  package       # Package version
  node          # Node.js section
  golang        # Go section
  venv          # virtualenv section
  exec_time     # Execution time
  line_sep      # Line break
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

# ------------------------------------------------------------------------------
# Auto venv
# ------------------------------------------------------------------------------

function auto_venv() {
  DIR=$(pwd)

  while [[ $DIR =~ ^$HOME/ ]]; do
    if [[ -f $DIR/.venv/bin/activate ]]; then
      source $DIR/.venv/bin/activate
      return
    fi

    DIR=$(dirname $DIR)
  done

  if command -v deactivate 2>&1 >/dev/null; then
    deactivate
  fi
}

auto_venv

chpwd_functions=(${chpwd_functions[@]} "auto_venv")

# ------------------------------------------------------------------------------
# Nvim Hooks
# ------------------------------------------------------------------------------

function nvim_on_cd() {
  if [[ ! -z $NVIM ]]; then
    nvim --server $NVIM --remote-send "<c-\\><c-n>:cd $(pwd) | lua SAVE_BUFFER_CWD()<cr>i"
  fi
}

function nvim_on_exit() {
  if [[ ! -z $NVIM ]] && [[ $- == *i* ]]; then
    nvim --server $NVIM --remote-send "<c-\\><c-n>:lua RESTORE_TERM_WINDOW_BUFFER(); print(' ')<cr>i"
  fi
}

chpwd_functions=(${chpwd_functions[@]} "nvim_on_cd")
zshexit_functions=(${zshexit_functions[@]} "nvim_on_exit")

# ------------------------------------------------------------------------------
# Alias / Functions
# ------------------------------------------------------------------------------

alias ls='ls --color=auto'

function git_ls() {
  git fetch --prune --quiet
  git branch --remotes --sort=committerdate | tac
}

# ------------------------------------------------------------------------------
# Personal vs Work
# ------------------------------------------------------------------------------

if [[ -f $ZDOTDIR/.zwork ]]; then
  source $ZDOTDIR/.zwork
else
  source $ZDOTDIR/.zhome
fi
