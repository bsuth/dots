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
# Zgenom
# ------------------------------------------------------------------------------

export ZGENOM_ROOT="$HOME/extern/zgenom"

if [[ ! -d $ZGENOM_ROOT ]]; then
  echo "Installing zgenom"
  mkdir -p $ZGENOM_ROOT
  git clone https://github.com/jandamm/zgenom.git $ZGENOM_ROOT
fi

source "$ZGENOM_ROOT/zgenom.zsh"

zgenom load zsh-users/zsh-completions
zgenom load zsh-users/zsh-autosuggestions
zgenom load z-shell/F-Sy-H
zgenom load z-shell/H-S-MW
zgenom load spaceship-prompt/spaceship-prompt spaceship

autoload -U promptinit; promptinit

zgenom autoupdate
! zgenom saved && zgenom save

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
  # hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  # gradle        # Gradle section
  # maven         # Maven section
  node          # Node.js section
  # ruby          # Ruby section
  # elixir        # Elixir section
  # xcode         # Xcode section
  # swift         # Swift section
  golang        # Go section
  # php           # PHP section
  # rust          # Rust section
  # haskell       # Haskell Stack section
  # julia         # Julia section
  # docker        # Docker section
  # aws           # Amazon Web Services section
  # gcloud        # Google Cloud Platform section
  # venv          # virtualenv section
  # conda         # conda virtualenv section
  # pyenv         # Pyenv section
  # dotnet        # .NET section
  # ember         # Ember.js section
  # kubectl       # Kubectl context section
  # terraform     # Terraform workspace section
  # ibmcloud      # IBM Cloud section
  exec_time     # Execution time
  line_sep      # Line break
  # battery       # Battery level and status
  # vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

# ------------------------------------------------------------------------------
# Hooks
# ------------------------------------------------------------------------------

function on_cd() {
  if [[ ! -z $NVIM ]]; then
    nvim --server $NVIM --remote-send "<c-\\><c-n>:cd $(pwd) | lua SAVE_BUFFER_CWD()<cr>i"
  fi
}

function on_exit() {
  if [[ ! -z $NVIM ]]; then
    nvim --server $NVIM --remote-send "<c-\\><c-n>:lua RESTORE_TERM_WINDOW_BUFFER(); print(' ')<cr>i"
  fi
}

chpwd_functions=(${chpwd_functions[@]} "on_cd")
zshexit_functions=(${zshexit_functions[@]} "on_exit")

# ------------------------------------------------------------------------------
# Alias / Functions
# ------------------------------------------------------------------------------

alias ls='ls --color=auto'
alias lj='luajit'

# https://joshajohnson.com/sea-picro/#documentation
alias qmk_chocofi='qmk flash -c -kb crkbd -km bsuth -e CONVERT_TO=promicro_rp2040'
alias qmk_ferris='qmk flash -c -kb "ferris/sweep" -km bsuth -e CONVERT_TO=promicro_rp2040'

alias erdejit='luajit ~/.luarocks/share/lua/5.1/erde/cli.lua'
alias erde5.1='lua5.1 ~/.luarocks/share/lua/5.1/erde/cli.lua'
alias erde5.2='lua5.2 ~/.luarocks/share/lua/5.2/erde/cli.lua'
alias erde5.3='lua5.3 ~/.luarocks/share/lua/5.3/erde/cli.lua'
alias erde5.4='lua5.4 ~/.luarocks/share/lua/5.4/erde/cli.lua'

function wm {
  SIZE="${1:-800x600}"
  export DISPLAY=:0
  Xephyr -br -ac -noreset -screen $SIZE :1 &
  export DISPLAY=:1
  sleep 0.1 # wait for display
  awesome
}

function lua_install {
  luarocks --local --lua-version="5.1" install "$1"
  luarocks --local --lua-version="5.2" install "$1"
  luarocks --local --lua-version="5.3" install "$1"
  luarocks --local --lua-version="5.4" install "$1"
}

function git_ls() {
  git fetch --prune --quiet
  git branch --remotes --sort=committerdate | tac
}

function git_cheat {
  GIT_ROOT=$(pwd)

  while [[ $GIT_ROOT != '/' ]] && [[ ! -d $GIT_ROOT/.git ]]; do
    GIT_ROOT=$(dirname "$GIT_ROOT")
  done

  if [[ $GIT_ROOT == '/' ]]; then
    echo "Not in a git repository"
    return 1
  fi

  git add .
  git commit -m 'update'
  git push
}

# ------------------------------------------------------------------------------
# Personal vs Work
# ------------------------------------------------------------------------------

if [[ -f $ZDOTDIR/.zwork ]]; then
  source $ZDOTDIR/.zwork
else
  source $ZDOTDIR/.zhome
fi
