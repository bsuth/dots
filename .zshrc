# ------------------------------------------------------------------------------
# Zsh
# ------------------------------------------------------------------------------

# Emacs Bindings
bindkey -e

# Options
setopt appendhistory autocd extendedglob nomatch notify
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
zgenom load sindresorhus/pure

autoload -U promptinit; promptinit
prompt pure
PURE_PROMPT_SYMBOL="➜"

zgenom autoupdate
! zgenom saved && zgenom save

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

export SHELL='/bin/zsh'
export EDITOR=nvim
export WORDCHARS=${WORDCHARS//[\/\.]}
export BROWSER='none'

export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=1000

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.luarocks/bin:$PATH"

# ------------------------------------------------------------------------------
# Lua
# ------------------------------------------------------------------------------

function _generate_lua_path_ {
  declare -a LUA_PATH_PARTS=(
    "./?.lua"
    "./?/init.lua"
    "$HOME/.luarocks/share/lua/$1/?.lua"
    "$HOME/.luarocks/share/lua/$1/?/init.lua"
    "/usr/local/share/lua/$1/?.lua"
    "/usr/local/share/lua/$1/?/init.lua"
    "/usr/share/lua/$1/?.lua"
    "/usr/share/lua/$1/?/init.lua"
    "/usr/lib/lua/$1/?.lua"
    "/usr/lib/lua/$1/?/init.lua"
  )
  GENERATED_LUA_PATH=$(IFS=";"; echo "${LUA_PATH_PARTS[*]}")

  declare -a LUA_CPATH_PARTS=(
    "./?.so"
    "$HOME/.luarocks/lib/lua/$1/?.so"
    "/usr/local/lib/lua/$1/?.so"
    "/usr/lib/lua/$1/?.so"
    "/usr/lib/lua/$1/loadall.so"
  )
  GENERATED_LUA_CPATH=$(IFS=";"; echo "${LUA_CPATH_PARTS[*]}")
}

_generate_lua_path_ "5.4"
export LUA_PATH_5_4="$GENERATED_LUA_PATH"
export LUA_CPATH_5_4="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.3"
export LUA_PATH_5_3="$GENERATED_LUA_PATH"
export LUA_CPATH_5_3="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.2"
export LUA_PATH_5_2="$GENERATED_LUA_PATH"
export LUA_CPATH_5_2="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.1"
export LUA_PATH="$GENERATED_LUA_PATH"
export LUA_CPATH="$GENERATED_LUA_CPATH"

# Add paths for .jit modules (required for `luajit -b`)
export LUA_PATH="$LUA_PATH;/usr/share/luajit-2.0.4/?/init.lua;/usr/share/luajit-2.0.4/?.lua"

export LUA_INCDIR="/usr/include/luajit-2.1"
export LUA_LIBDIR="/usr/include/luajit-2.1"

# ------------------------------------------------------------------------------
# Hooks
# ------------------------------------------------------------------------------

function on_cd() {
  (python3 $HOME/dots/nvim/onshellcd.py &)
}

chpwd_functions=(${chpwd_functions[@]} "on_cd")

# ------------------------------------------------------------------------------
# Alias / Functions
# ------------------------------------------------------------------------------

alias lj='luajit'

function gls() {
  git fetch --prune --quiet
  git ls-remote origin | rg refs/head | sed -E "s/.*refs\/heads\/(.*)/\1/"
}

function ansi() {
  setxkbmap us
  ln -sf ~/dots/.ansi.Xmodmap ~/.Xmodmap
  xmodmap ~/.Xmodmap
}

function hhkb() {
  setxkbmap us
  ln -sf ~/dots/.hhkb.Xmodmap ~/.Xmodmap
  xmodmap ~/.Xmodmap
}

function wm {
  SIZE="${1:-800x600}"
  export DISPLAY=:0
  Xephyr -br -ac -noreset -screen $SIZE :1 &
  export DISPLAY=:1
  sleep 0.1 # wait for display
  awesome
}

# ------------------------------------------------------------------------------
# Projects
# ------------------------------------------------------------------------------

ERDE_ROOT="$HOME/repos/erde"

if [[ $LUA_PATH != *"$ERDE_ROOT"* ]]; then
  LUA_PATH="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH"
fi

function erde() {
  $HOME/repos/erde/bin/erde $@
}

# ------------------------------------------------------------------------------
# Personal vs Work
# ------------------------------------------------------------------------------

if [[ -f $HOME/dots/.zshwork ]]; then
  source $HOME/dots/.zshwork
else
  source $HOME/dots/.zshhome
fi
